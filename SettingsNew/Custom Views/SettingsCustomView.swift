//
//  SettingsCustomView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsCustomView: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    let identifier: Settings.ViewIdentifier
    
    var body: some View {
        VStack {
            switch identifier {
            case .highlightsPreview:
                SettingsHighlightsPreview(model: model, realmModel: realmModel)
            case .highlightsIcon:
                SettingsHighlightsIcon(model: model, realmModel: realmModel)
            case .highlightsColor:
                SettingsHighlightsColor(model: model, realmModel: realmModel)
            case .photosGridSize:
                SettingsPhotoGridSize(model: model, realmModel: realmModel)
            case .cameraHapticFeedbackLevel:
                SettingsCameraHapticFeedback(model: model, realmModel: realmModel)
            case .credits:
                SettingsCredits(model: model, realmModel: realmModel)
            case .licenses:
                SettingsLicenses(model: model, realmModel: realmModel)
            case .links:
                SettingsLinks(model: model, realmModel: realmModel)
            }
        }
    }
}
