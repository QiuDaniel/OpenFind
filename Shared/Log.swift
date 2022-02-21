//
//  Log.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

enum Log {
    enum Level: String {
        case error = "Error"
        case warning = "Warning"
        case log = "Log"
    }
    
    static func print(_ item: Any, _ level: Level? = .log) {
        if let level = level {
            Swift.print("[\(level)] - \(item)")
        } else {
            Swift.print(item)
        }
    }
}

