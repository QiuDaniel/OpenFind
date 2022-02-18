//
//  PhotosSlidesViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class PhotoSlidesSection: Hashable {
    let id = 0
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PhotoSlidesSection, rhs: PhotoSlidesSection) -> Bool {
        lhs.id == rhs.id
    }
}

class PhotosSlidesViewController: UIViewController, Searchable {
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? /// nil to always have blur
    var updateSearchBarOffset: (() -> Void)?
    
    var model: PhotosViewModel
    var searchViewModel: SearchViewModel
    
    @IBOutlet var containerViewTopC: NSLayoutConstraint!
    @IBOutlet var containerView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    lazy var flowLayout = PhotosSlidesCollectionLayout(model: model)
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<PhotoSlidesSection, FindPhoto>
    typealias Snapshot = NSDiffableDataSourceSnapshot<PhotoSlidesSection, FindPhoto>

    // MARK: - Dismissal
    let dismissPanGesture = UIPanGestureRecognizer()
    var isInteractivelyDismissing: Bool = false
    weak var transitionAnimator: PhotosTransitionDismissAnimator? /// auto set via the transition animator
    
    init?(
        coder: NSCoder,
        model: PhotosViewModel,
        searchViewModel: SearchViewModel
    ) {
        self.model = model
        self.searchViewModel = searchViewModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photo"
        navigationItem.largeTitleDisplayMode = .never
        
        setup()
        setupDismissGesture()
        containerViewTopC.constant = searchViewModel.getTotalHeight()
        update(animate: false)
        
        if
            let slidesState = model.slidesState,
            let index = slidesState.findPhotos.firstIndex(where: {
                $0.photo == slidesState.startingPhoto
            })
        {
            model.slidesState?.currentIndex = index
            
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: index.indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Tab.Frames.excluded[.photosSlidesItemCollectionView] = collectionView.windowFrame()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Tab.Frames.excluded[.photosSlidesItemCollectionView] = nil
    }
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateSearchBarOffset?()
        containerViewTopC.constant = searchViewModel.getTotalHeight()
    }
}