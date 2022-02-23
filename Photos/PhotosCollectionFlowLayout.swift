//
//  PhotosCollectionFlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

struct PhotosSectionLayout {
    var categorization: PhotosSection.Categorization
    var headerLayoutAttributes = UICollectionViewLayoutAttributes()
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
}
class PhotosCollectionFlowLayout: UICollectionViewFlowLayout {
    var model: PhotosViewModel
    
    init(model: PhotosViewModel) {
        self.model = model
        super.init()
    }
    
    /// boilerplate code
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        let boundsChanged = newBounds.size != collectionView?.bounds.size
        context.invalidateFlowLayoutAttributes = boundsChanged
        context.invalidateFlowLayoutDelegateMetrics = boundsChanged
        return context
    }
    
    var sectionLayouts = [PhotosSectionLayout]()
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    var columnWidth = CGFloat(0) /// width of each column. Needed for bounds change calculations
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    /// get the number of columns and each column's width from available bounds + insets
    func getColumns(bounds: CGFloat, insets: UIEdgeInsets) -> (Int, CGFloat) {
        let availableWidth = bounds
            - PhotosConstants.sidePadding * 2
            - insets.left
            - insets.right
        
        let numberOfColumns = Int(availableWidth / PhotosConstants.minCellWidth)
        
        /// space between columns
        let columnSpacing = CGFloat(numberOfColumns - 1) * PhotosConstants.cellSpacing
        let columnWidth = (availableWidth - columnSpacing) / CGFloat(numberOfColumns)
        
        return (numberOfColumns, columnWidth)
    }
    
    override func prepare() { /// configure the cells' frames
        super.prepare()
        guard let collectionView = collectionView else { return }
        var sectionLayouts = [PhotosSectionLayout]()
        
        let (numberOfColumns, columnWidth) = getColumns(bounds: collectionView.bounds.width, insets: collectionView.safeAreaInsets)
        self.columnWidth = columnWidth
        
        var columnOffsets = [CGSize]()
        for columnIndex in 0 ..< numberOfColumns {
            let initialXOffset = PhotosConstants.sidePadding
            let additionalXOffset = CGFloat(columnIndex) * columnWidth
            var leftSpacing = CGFloat(0)
            
            /// add LEFT spacing if not first index
            if columnIndex != 0 {
                leftSpacing = CGFloat(columnIndex) * PhotosConstants.cellSpacing
            }
            
            let offset = CGSize(width: initialXOffset + additionalXOffset + leftSpacing, height: 0)
            columnOffsets.append(offset)
        }
        
        for sectionIndex in model.sections.indices {
            let section = model.sections[sectionIndex]
            let photos = section.photos
            for photoIndex in photos.indices {
                
                /// sometimes there are no `columnOffsets` due to `availableWidth` being too small
                if let shortestColumnIndex = columnOffsets.indices.min(by: { columnOffsets[$0].height < columnOffsets[$1].height }) {
                    let columnOffset = columnOffsets[shortestColumnIndex]
                    let cellFrame = CGRect(
                        x: columnOffset.width,
                        y: columnOffset.height,
                        width: columnWidth,
                        height: columnWidth
                    )
                
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: photoIndex, section: sectionIndex))
                    attributes.frame = cellFrame
                    columnOffsets[shortestColumnIndex].height += cellFrame.height + PhotosConstants.cellSpacing
                    
                    if let existingSectionLayoutIndex = sectionLayouts.firstIndex(where: { $0.categorization == section.categorization }) {
                        sectionLayouts[existingSectionLayoutIndex].layoutAttributes.append(attributes)
                    } else {
                        let newSectionLayout = PhotosSectionLayout(categorization: section.categorization, layoutAttributes: [attributes])
                        sectionLayouts.append(newSectionLayout)
                    }
                }
            }
        }
        
        let tallestColumnOffset = columnOffsets.max(by: { $0.height < $1.height }) ?? .zero
        contentSize = CGSize(
            width: collectionView.bounds.width
                - collectionView.safeAreaInsets.left
                - collectionView.safeAreaInsets.right,
            height: tallestColumnOffset.height
        )
        self.sectionLayouts = sectionLayouts
    }
    
    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionLayouts[safe: indexPath.section]?.layoutAttributes[safe: indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        /// edge cells don't shrink, but the animation is perfect
        return sectionLayouts.map { $0.layoutAttributes }.joined().filter { rect.intersects($0.frame) } /// try deleting this line
    }
}
