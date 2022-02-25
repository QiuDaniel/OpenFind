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
            cellProvider: { collectionView, indexPath, findPhoto -> UICollectionViewCell? in

                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "PhotosResultsCell",
                    for: indexPath
                ) as! PhotosResultsCell

                if let highlightsViewController = self.model.resultsState?.findPhotos[indexPath.item].cellHighlightsViewController {
                    self.removeChildViewController(highlightsViewController)
                    self.model.resultsState?.findPhotos[indexPath.item].cellHighlightsViewController = nil
                }
                
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

                cell.tapped = { [weak self] in
                    guard let self = self else { return }
                    self.presentSlides(startingAtFindPhoto: findPhoto)
                }
                
                
//                cell.appeared = { [weak self] in
//                    print("\(indexPath.item) appeared")
//                }
                
                self.didEndDisplayingResultsCell(cell: cell, index: indexPath.item)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.willDisplayResultsCell(cell: cell, index: indexPath.item)
                }
//                cell.disappeared = { [weak self] in
//                    print("\(indexPath.item) disappeared")
//                    self?.didEndDisplayingResultsCell(cell: cell, index: indexPath.item)
//                }

                return cell
            }
        )
        return dataSource
    }
}
