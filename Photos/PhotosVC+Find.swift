//
//  PhotosVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

/// control how to find
enum FindContext {
    case findingAfterNewPhotosAdded
    case findingAfterTextChange(firstTimeShowingResults: Bool)
    
    /// no need to scan again if:
    ///     - photo starred/unstarred
    ///     - photo added via live results
    case justFindFromExistingDoNotScan
}

extension PhotosViewController {
    /// find in all photos, populate `resultsState`, reload collection view
    func find(context: FindContext) {
        if !model.photosToScan.isEmpty, model.scanningState == .dormant {
            switch context {
            case .findingAfterNewPhotosAdded:
                if realmModel.photosScanOnAddition {
                    model.startScanning()
                }
            case .findingAfterTextChange:
                if realmModel.photosScanOnFind {
                    model.startScanning()
                }
            case .justFindFromExistingDoNotScan:
                break
            }
        }
        
        let realmModel = self.realmModel
        let photos = self.model.photos
        let stringToGradients = self.searchViewModel.stringToGradients
        
        Task.detached {
            let (allFindPhotos, starredFindPhotos, screenshotsFindPhotos) = await Finding.findAndGetFindPhotos(realmModel: realmModel, from: photos, stringToGradients: stringToGradients)
            
            await self.apply(allFindPhotos: allFindPhotos, starredFindPhotos: starredFindPhotos, screenshotsFindPhotos: screenshotsFindPhotos, context: context)
        }
    }
    
    @MainActor func apply(allFindPhotos: [FindPhoto], starredFindPhotos: [FindPhoto], screenshotsFindPhotos: [FindPhoto], context: FindContext) {
        let displayedFindPhotos: [FindPhoto]
        
        switch self.sliderViewModel.selectedFilter ?? .all {
        case .starred:
            displayedFindPhotos = starredFindPhotos
        case .screenshots:
            displayedFindPhotos = screenshotsFindPhotos
        case .all:
            displayedFindPhotos = allFindPhotos
        }
    
        model.resultsState = PhotosResultsState(
            displayedFindPhotos: displayedFindPhotos,
            allFindPhotos: allFindPhotos,
            starredFindPhotos: starredFindPhotos,
            screenshotsFindPhotos: screenshotsFindPhotos
        )
        
        if case .findingAfterTextChange(firstTimeShowingResults: let firstTimeShowingResults) = context {
            updateResults(animate: !firstTimeShowingResults)
        } else {
            updateResults() /// always update results anyway, for example when coming back from star
        }
        
        resultsHeaderViewModel.text = model.resultsState?.getResultsText() ?? ""
        
        if model.isSelecting {
            resetSelectingState()
            updateCollectionViewSelectionState()
        }
    }
}