//
//  RooseveltConnectLiveActivity.swift
//  RooseveltConnect
//
//  Created by Dev on 8/24/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RooseveltConnectAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct RooseveltConnectLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RooseveltConnectAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension RooseveltConnectAttributes {
    fileprivate static var preview: RooseveltConnectAttributes {
        RooseveltConnectAttributes(name: "World")
    }
}

extension RooseveltConnectAttributes.ContentState {
    fileprivate static var smiley: RooseveltConnectAttributes.ContentState {
        RooseveltConnectAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: RooseveltConnectAttributes.ContentState {
         RooseveltConnectAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: RooseveltConnectAttributes.preview) {
   RooseveltConnectLiveActivity()
} contentStates: {
    RooseveltConnectAttributes.ContentState.smiley
    RooseveltConnectAttributes.ContentState.starEyes
}
