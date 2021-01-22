//
//  SlideFindBar.swift
//  Find
//
//  Created by Zheng on 1/22/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class SlideFindBar: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var findBar: FindBar!
    @IBOutlet weak var promptLabel: UILabel!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurViewHeightC: NSLayoutConstraint!
    
    var hasPrompt = false /// to show prompt or not
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SlideFindBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        promptLabel.alpha = 0
        
        findBar.searchField.backgroundColor = UIColor.systemBackground
        findBar.searchField.textColor = UIColor.label
        findBar.searchField.tintColor = UIColor(named: "PhotosText")
        findBar.searchField.attributedPlaceholder = NSAttributedString(string: "Type here to find", attributes: [NSAttributedString.Key.foregroundColor : UIColor.label.withAlphaComponent(0.25)])
    }
}