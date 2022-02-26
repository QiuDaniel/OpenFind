//
//  HighlightsConstants.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit

enum HighlightsConstants {
    static var maximumHighlightTransitionProximity = CGFloat(0.07) /// 7% of the screen
    static var maximumHighlightTransitionProximitySquared = pow(maximumHighlightTransitionProximity, 2)
    static var maximumCyclesForLingeringHighlights = 3
}
