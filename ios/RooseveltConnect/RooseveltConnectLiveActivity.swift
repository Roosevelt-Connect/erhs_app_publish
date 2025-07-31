//
//  RooseveltConnectLiveActivity.swift
//  RooseveltConnect
//
//  Created by Dev on 7/24/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState // don't forget to add this line, otherwise, live activity will not display it.

     public struct ContentState: Codable, Hashable { }
     
     var id = UUID()
}

// Create shared default with custom group
let sharedDefault = UserDefaults(suiteName: "group.com.rooseveltconnect.liveactivities")!

struct RooseveltConnectLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            let period = sharedDefault.string(forKey: context.attributes.prefixedKey("period")) ?? "Class"
            let minutesLeft = sharedDefault.string(forKey: context.attributes.prefixedKey("minutesLeft")) ?? "--"

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(.white)
                    Text(period)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }

                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(minutesLeft) minutes remaining")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.cyan, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .activityBackgroundTint(.clear) // Let the gradient show through
            .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.attributes.id.uuidString.prefix(4)) // Optional unique ID
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(sharedDefault.string(forKey: context.attributes.prefixedKey("period")) ?? "Class")
                            .font(.headline)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(sharedDefault.string(forKey: context.attributes.prefixedKey("minutesLeft")) ?? "--") min left")
                        .font(.subheadline)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 4) {
                        Text("You're in:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(sharedDefault.string(forKey: context.attributes.prefixedKey("period")) ?? "Class")
                            .bold()

                        Text("Time remaining:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(sharedDefault.string(forKey: context.attributes.prefixedKey("minutesLeft")) ?? "--") minutes")
                            .font(.body)
                            .bold()
                    }
                }
            } compactLeading: {
                Text(sharedDefault.string(forKey: context.attributes.prefixedKey("period"))?.prefix(1) ?? "?")
                    .font(.caption)
            } compactTrailing: {
                Text(sharedDefault.string(forKey: context.attributes.prefixedKey("minutesLeft")) ?? "--")
                    .font(.caption)
            } minimal: {
                Image(systemName: "clock")
            }
            .widgetURL(URL(string: "https://www.roosevelt.edu"))
            .keylineTint(Color.purple)
        }
    }
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    return "\(id)_\(key)"
  }
}
