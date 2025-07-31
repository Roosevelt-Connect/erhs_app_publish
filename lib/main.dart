import 'pages/educators/educator_auth_page.dart';
import 'pages/students/auth_page.dart';
import 'themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:live_activities/live_activities.dart';
import 'firebase_options.dart';
import 'package:url_launcher/url_launcher.dart';

// /// Handle FCM in background to update Live Activity
// Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
//   await LiveActivities.instance.initialize(
//     appGroupId: 'group.com.rooseveltconnect.liveactivities',
//   );

//   final activityId = message.data['activityId'];
//   final contentState = message.data['contentState'];
//   if (activityId != null && contentState != null) {
//     // contentState must be JSON-serializable Map<String, dynamic>
//     await LiveActivities.instance.updateActivity(
//       activityId,
//       contentState: Map<String, dynamic>.from(
//         jsonDecode(contentState) as Map
//       ),
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // // Register background handler
  // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // // Foreground messages
  // FirebaseMessaging.onMessage.listen((message) async {
  //   await LiveActivities.instance.initialize(
  //     appGroupId: 'group.com.example.live'
  //   );

  //   final activityId = message.data['activityId'];
  //   final contentState = message.data['contentState'];
  //   if (activityId != null && contentState != null) {
  //     await LiveActivities.instance.updateActivity(
  //       activityId,
  //       contentState: Map<String, dynamic>.from(
  //         jsonDecode(contentState) as Map
  //       ),
  //     );
  //   }
  // });
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roosevelt Connect',
      debugShowCheckedModeBanner: false,
      theme: context.watch<ThemeProvider>().themeData,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool animate = false;

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  Future startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    setState(() {
      animate = true;
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MyHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    print("🟢 My actual main.dart is running!");
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffF99E43),
                Color(0xFFDA2323),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 35.0),
                  Lottie.asset('lib/assets/animations/splash.json',
                      repeat: false),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 50, // Dynamically center vertically
                left: 0,
                right: 0, // Ensure horizontal centering
                child: AnimatedOpacity(
                  opacity: animate ? 1.0 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "\n\nRoosevelt\nConnect",
                          style: GoogleFonts.abhayaLibre(
                            textStyle: TextStyle(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Image.asset(
                          "lib/assets/img/erhs_logo.png",
                          height: 200,
                          width: 200,
                          fit: BoxFit.fitHeight,
                          alignment: FractionalOffset.topCenter,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const LogoBanner(),
              Transform.translate(
                offset: const Offset(0, -50),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Text(
                            "Welcome",
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 50),
                          child: Text(
                            "To",
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Text(
                            "Eleanor",
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w100,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Text(
                            "High",
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w100,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Text(
                            "Roosevelt",
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Text(
                            "School",
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                width: 175.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 20, 40, 75),
                    side: const BorderSide(
                      color: Color.fromARGB(100, 20, 40, 75),
                    ),
                  ),
                  child: const Text("Sign in as Student"),
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                width: 175.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EducatorAuthPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 189, 74, 38),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 189, 74, 38)),
                  ),
                  child: const Text("Sign in as Educator"),
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                width: 175.0,
                child: ElevatedButton(
                  onPressed: () {
                    _launchURL("https://roosevelt.cnusd.k12.ca.us/");
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 20, 40, 75),
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color.fromARGB(255, 20, 40, 75),
                    ),
                  ),
                  child: const Text("Explore ERHS"),
                ),
              ),
              const SizedBox(height: 50.0),
              GradientBar(
                width: 285,
                colors: const [
                  Color.fromRGBO(38, 99, 202, 1),
                  Color.fromRGBO(76, 35, 147, 1),
                ],
              ),
              const SizedBox(height: 8.0),
              GradientBar(
                width: 200,
                colors: const [
                  Color.fromRGBO(230, 159, 5, 1),
                  Color.fromRGBO(204, 45, 16, 1),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoBanner extends StatelessWidget {
  const LogoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "lib/assets/img/erhs_logo.png",
      width: 400.0,
      height: 250.0,
      fit: BoxFit.fitHeight,
    );
  }
}

class GradientBar extends StatelessWidget {
  final double width;
  final List<Color> colors;

  const GradientBar({super.key, required this.width, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 50,
          width: width,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
        ),
        CustomPaint(
          painter: TrianglePainter(
            strokeColor: colors[0],
            strokeWidth: 10,
            paintingStyle: PaintingStyle.fill,
          ),
          child: const SizedBox(
            height: 50,
            width: 75,
          ),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter({
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(-3, y)
      ..lineTo(0, 0)
      ..lineTo(x, 0)
      ..lineTo(0, y);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
