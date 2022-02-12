//
//  PhotosController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class PhotosController {
    
    var model: PhotosViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    
    var searchViewModel: SearchViewModel
    var searchNavigationController: SearchNavigationController
    var viewController: PhotosViewController
    
    init(model: PhotosViewModel, toolbarViewModel: ToolbarViewModel, realmModel: RealmModel) {
        self.model = model
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        
        let searchViewModel = SearchViewModel(configuration: .photos)
        self.searchViewModel = searchViewModel
        
        let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    
    
        let searchNavigationController = SearchNavigationController.make(
            rootViewController: viewController,
            searchViewModel: searchViewModel,
            realmModel: realmModel,
            tabType: .lists
        )
        searchNavigationController.onWillBecomeActive = { viewController.willBecomeActive() }
        searchNavigationController.onDidBecomeActive = { viewController.didBecomeActive() }
        searchNavigationController.onWillBecomeInactive = { viewController.willBecomeInactive() }
        searchNavigationController.onDidBecomeInactive = { viewController.didBecomeInactive() }
        searchNavigationController.onBoundsChange = { (size, safeAreaInset) in
            viewController.boundsChanged(to: size, safeAreaInsets: safeAreaInset)
        }
        
        self.searchNavigationController = searchNavigationController
    }
}
