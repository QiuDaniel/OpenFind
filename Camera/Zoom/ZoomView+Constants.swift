//
//  ZoomView+Constants.swift
//  Camera
//
//  Created by Zheng on 11/20/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

struct C {
    static let containerEdgePadding = CGFloat(64)
    
    static var edgePadding = CGFloat(4)
    static var zoomFactorPadding = CGFloat(4)
    static var zoomFactorLength = CGFloat(44)
    
    static let minZoom = CGFloat(0.5)
    static let maxZoom = CGFloat(10)
    
    static let activationStartDistance = CGFloat(0.09)
    static let activationRange = CGFloat(0.06)
    
    
    /// how wide `positionRange` normally is
    static let normalPositionRange = 0.3
    
    
    static let timeoutTime = CGFloat(1.5)
    
    static var zoomFactors = [ZoomFactor]()
}
