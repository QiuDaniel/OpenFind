//
//  SearchNC+Transitioning.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SearchNavigationController {
    /// move the search bar based on the topmost view controller's `baseSearchBarOffset` and `additionalSearchBarOffset`
    func updateSearchBarOffset() {
        if let topViewController = navigation?.topViewController as? Searchable {
            let searchBarOffset = topViewController.baseSearchBarOffset + max(0, topViewController.additionalSearchBarOffset ?? 0)
            let searchBarHeight = topViewController.showSearchBar ? searchViewModel.getTotalHeight() : 0
            let promptOffset = searchBarOffset + searchBarHeight
            let promptHeight = getAdditionalSearchPromptHeight(for: topViewController)
            let barHeight = promptOffset + promptHeight
            
            searchContainerViewTopC?.constant = searchBarOffset
            detailsSearchPromptViewContainerTopC?.constant = promptOffset
            detailsSearchPromptViewContainerHeightC?.constant = promptHeight
            navigationBarBackgroundHeightC?.constant = barHeight
            
//            print("height: \(barHeight)")
            
            self.updateBlur(
                baseSearchBarOffset: topViewController.baseSearchBarOffset,
                additionalSearchBarOffset: topViewController.additionalSearchBarOffset
            )
        }
    }
    
    /// Make sure that the view controller doesn't have a nil `additionalSearchBarOffset` - in this case, always return 1
    func getViewControllerBlurPercentage(for viewController: Searchable) -> CGFloat {
        let percentage: CGFloat
        if let additionalSearchBarOffset = viewController.additionalSearchBarOffset {
            percentage = self.getBlurPercentage(
                baseSearchBarOffset: viewController.baseSearchBarOffset,
                additionalSearchBarOffset: additionalSearchBarOffset
            )
        } else {
            percentage = 1
        }
        return percentage
    }
    
    /// 0 is nil, 1 is blur
    func getBlurPercentage(baseSearchBarOffset: CGFloat?, additionalSearchBarOffset: CGFloat?) -> CGFloat {
        /// make sure `additionalSearchBarOffset` is negative (scrolling up)
        let additionalSearchBarOffset = additionalSearchBarOffset ?? 0
        guard additionalSearchBarOffset <= 0 else { return 0 }
        let percentage = additionalSearchBarOffset / -SearchNavigationConstants.blurFadeRange
        let constrainedPercentage = min(1, percentage)
        return constrainedPercentage
    }
    
    func updateBlur(baseSearchBarOffset: CGFloat?, additionalSearchBarOffset: CGFloat?) {
        /// make sure no transition is happening currently
        guard navigation.transitionCoordinator == nil else { return }
        
        if let additionalSearchBarOffset = additionalSearchBarOffset {
            let blurPercentage = self.getBlurPercentage(
                baseSearchBarOffset: baseSearchBarOffset,
                additionalSearchBarOffset: additionalSearchBarOffset
            )
            self.updateBlur(to: blurPercentage)
        } else {
            self.updateBlur(to: 1)
        }
    }
    
    func updateBlur(to blurPercentage: CGFloat) {
        animator?.fractionComplete = blurPercentage
        self.blurPercentage = blurPercentage
    }
}
