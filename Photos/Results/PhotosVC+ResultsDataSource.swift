//
//  PhotosVC+ResultsDataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension PhotosViewController {
    func updateResults(animate: Bool = true) {
        guard let resultsState = model.resultsState else { return }
        var resultsSnapshot = ResultsSnapshot()
        let section = PhotoSlidesSection()
        resultsSnapshot.appendSections([section])
        resultsSnapshot.appendItems(resultsState.findPhotos, toSection: section)
        resultsDataSource.apply(resultsSnapshot, animatingDifferences: animate)
    }

    func makeResultsDataSource() -> ResultsDataSource {
        let dataSource = ResultsDataSource(
            collectionView: resultsCollectionView,
            cellProvider: { collectionView, indexPath, cachedFindPhoto -> UICollectionViewCell? in

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PhotosResultsCell",
                    for: indexPath
                ) as! PhotosResultsCell

                /// get the current up-to-date FindPhoto first.
                guard let findPhoto = self.model.resultsState?.findPhotos.first(where: { $0.photo == cachedFindPhoto.photo }) else { return cell }

                cell.titleLabel.text = findPhoto.dateString()
                cell.resultsLabel.text = findPhoto.resultsString()
                cell.descriptionTextView.text = findPhoto.descriptionText

                // Request an image for the asset from the PHCachingImageManager.
                cell.representedAssetIdentifier = findPhoto.photo.asset.localIdentifier
                self.model.imageManager.requestImage(
                    for: findPhoto.photo.asset,
                    targetSize: PhotosConstants.thumbnailSize,
                    contentMode: .aspectFill,
                    options: nil
                ) { thumbnail, _ in
                    // UIKit may have recycled this cell by the handler's activation time.
                    // Set the cell's thumbnail image only if it's still showing the same asset.
                    if cell.representedAssetIdentifier == findPhoto.photo.asset.localIdentifier {
                        cell.imageView.image = thumbnail
                        self.model.photoToThumbnail[findPhoto.photo] = thumbnail
                    }
                }

                cell.highlightsViewController?.view.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    guard cell.representedAssetIdentifier == findPhoto.photo.asset.localIdentifier else { return }
                    let highlights = self.getHighlights(for: cell, with: findPhoto)
                    if let highlightsViewController = cell.highlightsViewController {
                        highlightsViewController.highlightsViewModel.highlights = highlights
                    } else {
                        let highlightsViewModel = HighlightsViewModel()
                        highlightsViewModel.highlights = highlights
                        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
                        self.addChildViewController(highlightsViewController, in: cell.descriptionHighlightsContainerView)
                        cell.highlightsViewController = highlightsViewController
                    }

                    UIView.animate(withDuration: 0.1) {
                        cell.highlightsViewController?.view.alpha = 1
                    }
                }

                cell.tapped = { [weak self] in
                    guard let self = self else { return }
                    self.presentSlides(startingAtFindPhoto: findPhoto)
                }

                return cell
            }
        )
        return dataSource
    }
}
