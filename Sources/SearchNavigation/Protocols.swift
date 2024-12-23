//
//  Protocols.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

protocol Searchable: UIViewController {
    var showSearchBar: Bool { get set }
    var baseSearchBarOffset: CGFloat { get set }
    var additionalSearchBarOffset: CGFloat? { get set }
}

/// check if a view controller's name == something
protocol NavigationNamed: UIViewController {
    var name: NavigationName? { get set }
}

enum NavigationName {
    case listsDetail
    case photosDetail
}

protocol InteractivelyDismissible: UIViewController {
    var isInteractivelyDismissing: Bool { get set }
}
