//
//  SearchVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/11/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension SearchViewController {
    func listen() {
        listenToDefaults()
        listenToCollectionView()
        listenToToolbar()
        listenToKeyboard()
        
        realmModel.$lists
            .dropFirst()
            .sink { [weak self] lists in
                guard let self = self else { return }
                self.listsChanged(newLists: lists)
            }
            .store(in: &realmModel.cancellables)
        
        searchViewModel.dismissKeyboard = { [weak self] in
            guard let self = self else { return }

            /// calling superview actually forces end editing
            self.view.superview?.endEditing(true)
        }
        
        searchViewModel.getShouldKeepWhitespace = { [weak self] in
            guard let self = self else { return false }
            return self.realmModel.findingKeepWhitespace
        }
        
        searchViewModel.enabledChanged = { [weak self] in
            guard let self = self else { return }
            let enabled = self.searchViewModel.enabled
            
            self.view.isUserInteractionEnabled = enabled
            
            for index in self.searchViewModel.fields.indices {
                if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                    if enabled {
                        cell.textField.accessibilityHint = self.searchViewModel.configuration.voiceOverDescription
                    } else {
                        cell.textField.accessibilityHint = "\(self.searchViewModel.configuration.voiceOverDescription). Permissions are needed."
                    }
                }
            }
        }
    }

    func listenToCollectionView() {
        collectionViewModel.getFullCellWidth = { [weak self] index in
            self?.getWidthOfExpandedCell(for: index) ?? 300
        }
        collectionViewModel.highlightAddNewField = { [weak self] shouldHighlight in
            self?.highlight(shouldHighlight)
        }
        
        collectionViewModel.convertAddNewCellToRegularCell = { [weak self] completion in
            
            /// make it blue first
            self?.highlight(true, generateHaptics: true, animate: false)
            self?.convertAddNewCellToRegularCell { [weak self] in
                self?.addNewCellToRight()
                completion()
            }
        }
        
        /// this will update the fields. No need to notify though, otherwise there will be an unwanted animation of the "Cancel" button.
        collectionViewModel.focusedCellIndexChanged = { [weak self] oldCellIndex, newCellIndex in
            guard let self = self else { return }
            
            /// only active the newly-focused cell if previously a text field was active
            var activateNewCell = false
            if let oldCellIndex = oldCellIndex {
                if let cell = self.searchCollectionView.cellForItem(at: oldCellIndex.indexPath) as? SearchFieldCell {
                    if self.searchViewModel.fields.indices.contains(oldCellIndex) {
                        var field = self.searchViewModel.fields[oldCellIndex]
                        field.showingDeleteButton = false
                        self.searchViewModel.updateField(at: oldCellIndex, with: field, notify: false)
                    }

                    cell.activate(false)
                    
                    if cell.textField.isFirstResponder {
                        cell.resignFirstResponder()
                        activateNewCell = true
                    }
                }
            }
            if let newCellIndex = newCellIndex, self.searchViewModel.fields.indices.contains(newCellIndex) {
                if let cell = self.searchCollectionView.cellForItem(at: newCellIndex.indexPath) as? SearchFieldCell {
                    if activateNewCell {
                        cell.textField.becomeFirstResponder()
                    }
                    cell.activate(true)
                }
            }
        }
    }
}
