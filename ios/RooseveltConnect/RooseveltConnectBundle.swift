//
//  RooseveltConnectBundle.swift
//  RooseveltConnect
//
//  Created by Dev on 7/31/25.
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
