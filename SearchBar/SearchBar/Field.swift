//
//  Field.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

struct Field {
    var value = Value.string("")
    
    /// delete button deletes the entire field
    /// clear button is normal, shown when is editing no matter what
    var showingDeleteButton = false
    
    
    /// width of text label + side views, nothing more
    var fieldHuggingWidth = CGFloat(200)
    
    
    enum Value {
        case string(String)
        case list(List)
        case addNew
    }
    
    
    func getText() -> String {
        switch self.value {
        case .string(let string):
            return string
        case .list(let list):
            return list.name
        case .addNew:
            return "Add Word"
        }
    }
}

struct List {
    var name = ""
    var desc = ""
    var contents = [String]()
    var iconImageName = ""
    var iconColorName = ""
    var dateCreated = Date()
}

struct FieldOffset {
    var fullWidth = CGFloat(0)
    var percentage = CGFloat(0)
    var shift = CGFloat(0) /// already multiplied by percentage
    var alpha = CGFloat(1) /// percent visible of add new
}

open class FieldLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var fullOrigin = CGFloat(0) /// origin when expanded
    var fullWidth = CGFloat(0) /// width when expanded
    var percentage = CGFloat(0) /// percentage shrunk
    
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! FieldLayoutAttributes
        copy.fullOrigin = fullOrigin
        copy.fullWidth = fullWidth
        copy.percentage = percentage
        
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? FieldLayoutAttributes else { return false }
        guard
            attributes.fullOrigin == fullOrigin,
            attributes.fullWidth == fullWidth,
            attributes.percentage == percentage
        else { return false }
    
        return super.isEqual(object)
    }
    
}
