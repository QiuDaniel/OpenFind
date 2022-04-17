//
//  LaunchCVC+Delegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension LaunchContentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? LaunchContentCell else { return }
        let identifier = model.pages[indexPath.item]

        if let viewController = cell.viewController {
            viewController.pageViewModel.identifier = identifier
        } else {
            let viewController = LaunchPageViewController(model: model, identifier: identifier)
            cell.viewController = viewController
            addChildViewController(viewController, in: cell.contentView)
        }
    }
}
