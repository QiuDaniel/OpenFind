//
//  TabBar+Photos.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

enum PhotoSlideAction {
    case share
    case star
    case cache
    case delete
    case info
    
}
extension TabBarView {
    func showPhotoSlideControls(show: Bool) {
        if show {
            controlsReferenceView.isUserInteractionEnabled = true
            controlsReferenceView.addSubview(photoSlideControls)
            photoSlideControls.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            photoSlideControls.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.stackView.alpha = 0
                self.photoSlideControls.alpha = 1
            }
            photoSlideControls.isUserInteractionEnabled = true
            
        } else {
            controlsReferenceView.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.3) {
                self.stackView.alpha = 1
                self.photoSlideControls.alpha = 0
            } completion: { _ in
                self.photoSlideControls.removeFromSuperview()
            }
        }
        
    }
    func dimPhotoSlideControls(dim: Bool) {
        if dim {
            photoSlideControls.alpha = 0.5
            photoSlideControls.isUserInteractionEnabled = false
        } else {
            photoSlideControls.alpha = 1
            photoSlideControls.isUserInteractionEnabled = true
        }
    }
}
