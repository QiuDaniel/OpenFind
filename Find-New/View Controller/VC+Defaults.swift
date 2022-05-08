//
//  VC+Defaults.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import StoreKit
import UIKit

extension ViewController {
    func listenToDefaults() {
        self.listen(
            to: RealmModelData.experiencePoints.key,
            selector: #selector(self.experiencePointsChanged)
        )
    }

    @objc func experiencePointsChanged() {
        switch realmModel.experiencePoints {
        case 50, 100, 200:
            self.requestRate()
        default: break
        }
    }

    func requestRate() {
        SKStoreReviewController.requestReview()
    }
}
