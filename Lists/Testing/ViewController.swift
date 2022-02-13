//
//  ViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let realmModel = RealmModel()
    lazy var lists: ListsController = ListsBridge.makeController(
        model: ListsViewModel(),
        toolbarViewModel: ToolbarViewModel(),
        realmModel: realmModel
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        realmModel.loadSampleLists()
        realmModel.loadLists()
        addChildViewController(lists.searchNavigationController, in: view)
    }
}
