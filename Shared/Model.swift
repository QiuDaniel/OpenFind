//
//  Model.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

enum Value {
    case word(Word)
    case list(List)
}

struct Word {
    var id = UUID()
    var string = ""
    var color: UInt = 0x00AEEF
}

struct List {
    var id = UUID()
    var name = ""
    var desc = ""
    var image = ""
    var color: UInt = 0x00AEEF
    var words = [String]()
    var dateCreated = Date()

}
