//
//  CollectionFlowLayout.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 19.09.15.
//  Copyright (c) 2015 Igor Ponomarenko. All rights reserved.
//

import Foundation

// MARK: constants

let cellHeight = CGFloat(100)
let cellWidth = CGFloat(100)
let headerHeight = CGFloat(100)
let headerWidth = CGFloat(100)

// MARK: CollectionFlowLayout

class CollectionFlowLayout: UICollectionViewFlowLayout {
    
    var sections: Array<Section> = Array()
    
    
    // MARK: Properties
    
    var boundsWidth: CGFloat {
        return self.collectionView!.bounds.size.width
    }
    
    var boundsHeight: CGFloat {
        return self.collectionView!.bounds.size.height
    }
    
    var xContentOffset: CGFloat {
        return self.collectionView!.contentOffset.x
    }
    
    var yContentOffset: CGFloat {
        return self.collectionView!.contentOffset.y
    }
    
    // MARK: Overrides
    
    override func prepareLayout() {
        super.prepareLayout()
        
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        sectionInset = UIEdgeInsetsMake(20, 70, 10, 10)
        //headerReferenceSize = CGSizeMake(headerWidth, headerHeight)
        
        itemSize = CGSizeMake(cellWidth, cellHeight)
        
        minimumLineSpacing = CGFloat(0)
        minimumInteritemSpacing = CGFloat(0)
        
        sections.removeAll(keepCapacity: true)
        
        for var i = 0; i < collectionView!.numberOfSections(); ++i {
            var section = Section()
            section.index = i
            section.itemsCount = collectionView!.numberOfItemsInSection(i)
            sections.append(section)
            
            section.makeCalculation(self)
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        var width: CGFloat = 0
        for section in sections {
            width += section.frame.width
        }
        
        return CGSizeMake(width, collectionView!.bounds.height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {

        var result: Array<AnyObject> = Array()
        
        let sections = sectionsInRect(rect)
        
        for section in sections {
            var cells = section.cellsInRect(rect)
            for cell in cells {
                let cellIndexPath = NSIndexPath(forRow: cell.index, inSection: section.index)
                
                NSLog("cellIndexPath row = \(cellIndexPath.row) section = \(cellIndexPath.section)")
                
                let cellLayoutAttribute = layoutAttributesForItemAtIndexPath(cellIndexPath)
                
                cellLayoutAttribute.frame = cell.frame
                result.append(cellLayoutAttribute)
            }
        }
        
//        let headerIndexPath = NSIndexPath(forItem: 0, inSection: 0)
//        let headerLayoutAttribute = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: headerIndexPath)
//        result.append(headerLayoutAttribute)
        
        
        return result
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let layoutAttribute = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
        
        return layoutAttribute
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let layoutAttribute = super.layoutAttributesForItemAtIndexPath(indexPath)
        return layoutAttribute
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: Private functions
    
    private func sectionsInRect(rect: CGRect) -> [Section] {
        var result: Array<Section> = Array()
        
        for section in sections {
            if CGRectIntersectsRect(rect, section.frame) {
                result.append(section)
            }
        }
        
        return result
    }
}