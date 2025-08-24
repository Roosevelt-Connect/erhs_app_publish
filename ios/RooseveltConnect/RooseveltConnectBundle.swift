//
//  RooseveltConnectBundle.swift
//  RooseveltConnect
//
//  Created by Dev on 8/24/25.
//

import WidgetKit
import SwiftUI

@main
struct RooseveltConnectBundle: WidgetBundle {
    var body: some Widget {
        RooseveltConnect()
        RooseveltConnectControl()
        RooseveltConnectLiveActivity()
    }
}
