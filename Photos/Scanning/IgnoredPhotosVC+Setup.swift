//
//  IgnoredPhotosVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit
import SwiftUI

extension IgnoredPhotosViewController {
    func setup() {
        setupCollectionView()
        setupNavigationBar()
        setupToolbar()
    }

    func setupCollectionView() {
        collectionView.register(PhotosCollectionCell.self, forCellWithReuseIdentifier: "PhotosCollectionCell")

        view.addSubview(collectionContainer)
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionContainer.topAnchor.constraint(equalTo: view.topAnchor),
            collectionContainer.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        collectionContainer.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()

        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.delaysContentTouches = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .always
    }

    func setupNavigationBar() {
        let selectButton = UIBarButtonItem(
            title: getSelectButtonTitle(),
            style: .plain,
            target: self,
            action: #selector(selectPressed)
        )

        navigationItem.rightBarButtonItem = selectButton
        self.selectBarButton = selectButton
    }
    
    func setupToolbar() {
        view.addSubview(toolbarContainer)
        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbarContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolbarContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolbarContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            toolbarContainer.heightAnchor.constraint(equalToConstant: ConstantVars.tabBarContentHeight),
            toolbarContainer.topAnchor.constraint(equalTo: collectionContainer.bottomAnchor)
        ])
        
        let hostingController = UIHostingController(rootView: toolbarView)
        addChildViewController(hostingController, in: toolbarContainer)
    }

    @objc func selectPressed() {
        toggleSelect()
    }
}