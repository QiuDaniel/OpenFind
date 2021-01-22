//
//  PhotoSlidesVC+FindBar.swift
//  Find
//
//  Created by Zheng on 1/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SnapKit

extension PhotoSlidesViewController {
    func setupFindBar() {
        let slideFindBar = SlideFindBar()
        view.addSubview(slideFindBar)
        
        slideFindBar.snp.makeConstraints { (make) in
            self.slideFindBarTopC = make.top.equalTo(view.safeArea.top).offset(-45).constraint
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(80)
        }
        view.layoutIfNeeded()
        
    }
    
    
    @objc func findPressed(sender: UIBarButtonItem) {
        print("Find")
        if slideFindBarTopC == nil {
            setupFindBar()
        }
        
        findPressed.toggle()
        
        if findPressed {
            slideFindBarTopC?.update(offset: 0)
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
                if self.slideFindBar?.hasPrompt == true {
                    self.slideFindBar?.promptLabel.alpha = 1
                }
                self.slideFindBar?.alpha = 1
            }
        } else {
            slideFindBarTopC?.update(offset: -45)
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.slideFindBar?.promptLabel.alpha = 0
                self.slideFindBar?.alpha = 0
            }
        }
    }
}
