//
//  SearchViewController.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

public class SearchViewController: UIViewController {
    
    var fields = [Field]()
    
    lazy var searchCollectionViewFlowLayout: SearchCollectionViewFlowLayout = {
        let flowLayout = SearchCollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getFullCellWidth = { [weak self] index in
            return self?.widthOfExpandedCell(for: index) ?? 300
        }
        flowLayout.getFields = { [weak self] in
            return self?.fields ?? [Field]()
        }
        flowLayout.highlightAddNewField = { [weak self] shouldHighlight in
            self?.highlight(shouldHighlight)
        }
        flowLayout.focusedCellIndexChanged = { [weak self] oldCellIndex, newCellIndex in
            guard let self = self else { return }
            if let oldCellIndex = oldCellIndex {
                self.fields[oldCellIndex].focused = false /// for cellForItemAt later, after cell reloads
                if let cell = self.searchCollectionView.cellForItem(at: oldCellIndex.indexPath) as? SearchFieldCell {
                    cell.field = self.fields[oldCellIndex] /// set it right now anyway
                }
            }
            if let newCellIndex = newCellIndex {
                self.fields[newCellIndex].focused = true
                if let cell = self.searchCollectionView.cellForItem(at: newCellIndex.indexPath) as? SearchFieldCell {
                    cell.field = self.fields[newCellIndex] /// set it right now anyway
                    cell.textField.becomeFirstResponder()
                }
            }
        }
        
        flowLayout.convertAddNewToRegularCellInstantly = { [weak self] completion in
            
            /// make it blue first
            self?.highlight(true, generateHaptics: true, animate: false)
            self?.convertAddNewCellToRegularCell() { [weak self] in
                self?.addNewCellToRight()
                completion()
            }
        }
        
        searchCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }()
    
    
    
    /// base view for everything
    @IBOutlet weak var baseView: UIView!
    
    /// blur background
    @IBOutlet weak var backgroundView: UIView!
    
    /// contains the search bar
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchCollectionView: SearchCollectionView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        fields = [
            Field(value: .string("Search Bar Medium Length")),
//            Field(value: .string("2. Hi.")),
//            Field(value: .string("3.a Medium text")),
//            Field(value: .string("3.b Medium text")),
//            Field(value: .string("3.c Medium text")),
//            Field(value: .string("3.d Medium text")),
//            Field(value: .string("4. Longer long long long long long text")),
//            Field(value: .string("5. Text")),
            Field(value: .addNew(""))
        ]
        

        setupCollectionViews()

    }
    
    
}

extension SearchViewController {
    func setupCollectionViews() {
//        searchCollectionView.clipsToBounds = false
//        searchCollectionView.layer.borderWidth = 3
//        searchCollectionView.layer.borderColor = UIColor.purple.cgColor
        
        /// actually important, when there's only 1 search bar
        searchCollectionView.alwaysBounceHorizontal = true
        
        searchCollectionView.decelerationRate = .fast
        searchCollectionView.showsHorizontalScrollIndicator = false
        
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.delaysContentTouches = true /// allow scrolling through text fields
        
        let bundle = Bundle(identifier: "com.aheze.SearchBar")
        let nib = UINib(nibName: "SearchFieldCell", bundle: bundle)
        searchCollectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        _ = searchCollectionViewFlowLayout /// initialize and set up
        
        searchCollectionView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }
    
    /// convert "Add New" cell into a normal field
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .ended:
            if searchCollectionViewFlowLayout.highlightingAddWordField {
                convertAddNewCellToRegularCell() { [weak self] in
                    self?.addNewCellToRight()
                }
            }
        default:
            break
        }
    }
}

