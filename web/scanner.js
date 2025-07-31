// filepath: /Users/dev/Documents/GitHub/erhs_app/web/scanner.js
let zxingCodeReader = null;
// let zxingVideoStream = null; // We might not need to manage this explicitly if decodeFromVideoDevice handles it
let zxingVideoElement = null; 

async function initWebScanner(videoElement, resultCallbackName, errorCallbackName) {
  if (typeof ZXing === 'undefined') {
    console.error('ZXing library not loaded.');
    if (window[errorCallbackName]) window[errorCallbackName]('ZXing library not loaded.');
    return;
  }

  await stopWebScannerInternal();

  zxingVideoElement = videoElement; 
  zxingCodeReader = new ZXing.BrowserMultiFormatReader(null, 500); // Added hints (null) and timeBetweenScansMillis (500ms)

  console.log('Attempting to initialize web scanner...');

  try {
    const videoInputDevices = await zxingCodeReader.listVideoInputDevices();
    if (videoInputDevices.length > 0) {
      const firstDeviceId = videoInputDevices[0].deviceId; 

      console.log(`Using video device: ${firstDeviceId}`);
      
      // The decodeFromVideoDevice method will handle the stream and video element internally for decoding.
      // We still need to ensure our videoElement is visible and ready if we want to show the preview.
      // For simplicity, let's ensure the video element is playing if we are showing it.
      // If zxing-js handles the video element display itself with decodeFromVideoDevice, 
      // we might not even need to set srcObject here.
      // However, to show a preview in *your* video element, you still need to set it up.
      
      // Setup your video element for preview (optional but good for UX)
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ video: { deviceId: firstDeviceId } });
        zxingVideoElement.srcObject = stream;
        await new Promise((resolve, reject) => {
            zxingVideoElement.onloadedmetadata = () => {
                zxingVideoElement.play().then(resolve).catch(reject);
            };
            zxingVideoElement.onerror = reject;
        });
        console.log("Video preview started.");
      } catch (previewError) {
        console.error("Could not start video preview:", previewError);
        // Continue without preview if it fails, scanner might still work if it uses its own video handling
      }


      // Use decodeFromVideoDevice for continuous scanning
      // This method takes the deviceId, the video element (or its ID) where the preview *can* be shown,
      // and a callback that is invoked for each successful decode.
      zxingCodeReader.decodeFromVideoDevice(firstDeviceId, zxingVideoElement, (result, error) => {
        if (result) {
          console.log('Scan successful:', result.getText());
          if (window[resultCallbackName]) window[resultCallbackName](result.getText());
          // Important: To stop continuous scanning, you typically call reset() on the reader.
          // We'll do this in stopWebScannerInternal, which is called after a successful scan.
          stopWebScannerInternal(); 
        }
        if (error) {
          if (!(error instanceof ZXing.NotFoundException) && 
              !(error instanceof ZXing.ChecksumException) && 
              !(error instanceof ZXing.FormatException)) {
            // Log more significant errors
            console.error('Scan error:', error);
          }
          // For NotFoundException, it just means no barcode was found in the current frame, which is normal.
        }
      });

      console.log('Continuous scanning started with decodeFromVideoDevice.');

    } else {
      console.error('No video input devices found.');
      if (window[errorCallbackName]) window[errorCallbackName]('No video input devices found.');
    }
  } catch (error) {
    console.error('Error initializing web scanner:', error);
    if (window[errorCallbackName]) window[errorCallbackName]('Initialization error: ' + (error.message || error));
    await stopWebScannerInternal();
  }
}

async function stopWebScannerInternal() {
  if (zxingCodeReader) {
    // This is the crucial call to stop any ongoing scanning operations like decodeFromVideoDevice
    zxingCodeReader.reset(); 
    zxingCodeReader = null; // Nullify it after resetting
    console.log('ZXing code reader reset and stopped.');
  }
  // Stop the stream associated with *our* video element if we explicitly started it
  if (zxingVideoElement && zxingVideoElement.srcObject) {
    const stream = zxingVideoElement.srcObject;
    stream.getTracks().forEach(track => track.stop());
    zxingVideoElement.srcObject = null;
    console.log('Video element stream stopped and cleared.');
  }
  // zxingVideoElement itself is managed by Dart's HtmlElementView, so we don't nullify it here.
}

// This is the function Dart will call to explicitly stop the scanner
async function stopWebScanner() {
  console.log('stopWebScanner called from Dart.');
  await stopWebScannerInternal();
}