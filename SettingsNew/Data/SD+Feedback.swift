//
//  SD+Feedback.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SettingsData {
    static var feedbackSection: SettingsSection = {
        /// general section
        .init(
            rows: [
                .init(
                    configuration: .link(
                        title: "Rate the App",
                        leftIcon: .template(iconName: "star.fill", backgroundColor: UIColor(hex: 0xFFB800)),
                        indicatorStyle: .modal,
                        destination: nil
                    ) {
                        rateTheApp?()
                    }
                ),
                .init(
                    configuration: .link(
                        title: "Report a Bug",
                        leftIcon: .template(iconName: "exclamationmark.triangle.fill", backgroundColor: UIColor(hex: 0xFF0000)),
                        indicatorStyle: .modal,
                        destination: nil
                    ) {
                        reportABug?()
                    }
                ),
                .init(
                    configuration: .link(
                        title: "Suggest New Features",
                        leftIcon: .template(iconName: "sparkles", backgroundColor: UIColor(hex: 0x9E00FF)),
                        indicatorStyle: .modal,
                        destination: nil
                    ) {
                        suggestNewFeatures?()
                    }
                ),
                .init(
                    configuration: .link(
                        title: "Help Center",
                        leftIcon: .template(iconName: "questionmark.circle.fill", backgroundColor: UIColor(hex: 0x44AB00)),
                        indicatorStyle: .modal,
                        destination: nil
                    ) {
                        helpCenter?()
                    }
                ),
                .init(
                    configuration: .link(
                        title: "Join the Discord",
                        leftIcon: .image(imageName: "DiscordIcon", inset: 5, backgroundColor: UIColor(hex: 0x5865F2)),
                        indicatorStyle: .modal,
                        destination: nil
                    ) {
                        joinTheDiscord?()
                    }
                )
            ]
        )
    }()
}