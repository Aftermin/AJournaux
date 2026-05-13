//
//  AJournauxWidgetLiveActivity.swift
//  AJournauxWidget
//
//  Created by Amén on 11-05-2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AJournauxWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AJournauxWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AJournauxWidgetAttributes.self) { context in
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

extension AJournauxWidgetAttributes {
    fileprivate static var preview: AJournauxWidgetAttributes {
        AJournauxWidgetAttributes(name: "World")
    }
}

extension AJournauxWidgetAttributes.ContentState {
    fileprivate static var smiley: AJournauxWidgetAttributes.ContentState {
        AJournauxWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AJournauxWidgetAttributes.ContentState {
         AJournauxWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AJournauxWidgetAttributes.preview) {
   AJournauxWidgetLiveActivity()
} contentStates: {
    AJournauxWidgetAttributes.ContentState.smiley
    AJournauxWidgetAttributes.ContentState.starEyes
}
