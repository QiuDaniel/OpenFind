//
//  PhotosVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension PhotosViewController {
    func listen() {
//        realmModel.$photosMinimumCellLength.sink { [weak self] photosMinimumCellLength in
//            guard let self = self else { return }
//            self.
//        }
//        .store(in: &realmModel.cancellables)
        
        listenToModel()
    }
    func listenToModel() {
        /// only called at first
        model.reload = { [weak self] in
            guard let self = self else { return }
            
            self.model.displayedSections = self.model.allSections
            self.update(animate: false)
        }
        
        /// call this after new external photos added, or star change
        model.reloadAfterStarChanged = { [weak self] in
            guard let self = self else { return }
            
            self.findAndUpdateDisplayedPhotos(context: .justFindFromExistingDoNotScan)
        }
        
        model.reloadAfterExternalPhotosChanged = { [weak self] in
            guard let self = self else { return }
            
            self.findAndUpdateDisplayedPhotos(context: .findingAfterNewPhotosAdded)
        }
        
        /// underlying arrays have already been updated, reload the UI.
        model.reloadAt = { [weak self] collectionViewIndexPath, resultsCollectionViewIndex, metadata in
            guard let self = self else { return }
            if let collectionViewIndexPath = collectionViewIndexPath {
                self.update(at: collectionViewIndexPath, with: metadata)
            }
            
            if let resultsCollectionViewIndex = resultsCollectionViewIndex {
                self.updateResults(at: resultsCollectionViewIndex, with: metadata)
            }
            
            if let currentPhoto = self.model.slidesState?.currentPhoto {
                self.model.slidesState?.viewController?.configureToolbar(for: currentPhoto)
            }
        }
        
        /// called when finding from slides or new results came live when scanning results
        model.photosWithQueuedSentencesAdded = { [weak self] photos in
            guard let self = self else { return }
            self.findAfterQueuedSentencesUpdate(in: photos)
        }
        model.scanningIconTapped = { [weak self] in
            guard let self = self else { return }
            self.searchViewModel.dismissKeyboard?()
            self.present(self.scanningNavigationViewController, animated: true)
        }
        
        model.updateFieldOverrides = { [weak self] fields in
            guard let self = self else { return }
            
            var newFields = self.searchViewModel.fields
            for index in newFields.indices {
                let field = self.searchViewModel.fields[index]
                if let matchingField = fields.first(where: { $0.id == field.id }) {
                    newFields[index].overrides = matchingField.overrides
                }
            }
            
            /// don't notify yet
            self.searchViewModel.updateFields(fields: newFields, notify: false)
        }
        searchViewModel.fieldsChanged = { [weak self] textChanged in
            guard let self = self else { return }
            
            if textChanged {
                self.findAndUpdateResultsState(context: .findingAfterTextChange)
                self.resultsHeaderViewModel.text = self.model.resultsState?.getResultsText() ?? ""
                
                let resultsStateExisted = self.model.resultsState != nil
                if resultsStateExisted {
                    self.updateResults()
                } else {
                    self.updateResults(animate: false)
                    if self.model.isSelecting {
                        self.resetSelectingState()
                        self.updateCollectionViewSelectionState()
                    }
                }
            } else {
                /// replace all highlights
                self.updateResultsHighlightColors()
            }
            
            if self.searchViewModel.isEmpty {
                self.showResults(false)
            } else {
                self.showResults(true)
            }
        }
        
        headerContentModel.sizeChanged = { [weak self] in
            guard let self = self else { return }
            
            self.resultsHeaderHeightC.constant = self.headerContentModel.size?.height ?? 0
            self.collectionView.setNeedsLayout()
            self.collectionView.layoutIfNeeded()
            self.resultsFlowLayout.invalidateLayout()
        }
        
        slidesSearchPromptViewModel.resetPressed = { [weak self] in
            guard let self = self else { return }
            self.slidesSearchViewModel.replaceInPlace(with: self.searchViewModel, notify: true)
            self.model.updateSlidesSearchCollectionView?()
        }
        
        model.reloadCollectionViewsAfterDeletion = { [weak self] in
            guard let self = self else { return }
            self.update()
            self.updateResults()
        }
        
        model.stopSelecting = { [weak self] in
            guard let self = self else { return }
            self.resetSelectingState()
        }
        model.shareSelected = { [weak self] in
            guard let self = self else { return }
            self.share(photos: self.model.selectedPhotos, model: self.model)
        }
    }
}
