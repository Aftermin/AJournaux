//
//  AJournauxWidgetBundle.swift
//  AJournauxWidget
//
//  Created by Amén on 11-05-2026.
//

import WidgetKit
import SwiftUI

@main
struct AJournauxWidgetBundle: WidgetBundle {
    var body: some Widget {
        PromptSingleWidget()
        ArcDaysSingleWidget()
        DotGridDaysSingleWidget()
        MomentsSingleWidget()
        AJournauxWidgetControl()
        AJournauxWidgetLiveActivity()
    }
}
