//
//  Utilities+Constraints.swift
//  Find
//
//  Created by Zheng on 11/23/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CGRect {
    func setAsConstraints(left: NSLayoutConstraint, top: NSLayoutConstraint, width: NSLayoutConstraint, height: NSLayoutConstraint) {
        left.constant = origin.x
        top.constant = origin.y
        width.constant = size.width
        height.constant = size.height
    }
}
