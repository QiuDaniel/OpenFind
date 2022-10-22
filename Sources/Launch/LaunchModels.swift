//
//  LaunchModels.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import RealityKit
import UIKit

/// Row of launch text
/// X X X X X X
struct LaunchTextRow: Identifiable {
    let id = UUID()
    var text = [LaunchText]()
}

struct LaunchText: Identifiable {
    let id = UUID()
    var character: String
    var isPartOfFindIndex: Int? /// if not nil, make blue
    
    // MARK: - RealityKit
    /// height, change this later
    var yOffset = Float(0)
    
    var additionalXOffset = Float(0)
    var additionalZOffset = Float(0)
    
    var color: UIColor {
        if isPartOfFindIndex != nil {
            return Colors.accent
        } else {
            return UIColor.clear
        }
    }
    
    // MARK: - SwiftUI
    var angle = CGFloat(0)
}
 
struct LaunchTile {
    var text: LaunchText
    var entity: ModelEntity
    var location: Location /// populate from index inside `LaunchTextRow`
    var initialTransform: Transform
    var midTransform: Transform
    var finalTransform: Transform? /// only for Find tiles

    struct Location: Equatable {
        var x: Int
        var z: Int
    }
}

enum LaunchPage: Int, CaseIterable {
    case empty = 0 /// first page
    case photos = 1
    case camera = 2
    case lists = 3
    case final = 4
}
