//
//  CollectionFlowLayout.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 19.09.15.
//  Copyright (c) 2015 Igor Ponomarenko. All rights reserved.
//

import Foundation
import UIKit

class VHCollectionFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: constants
    
    let cellHeight = CGFloat(70)
    let cellWidth = CGFloat(70)
    let headerHeight = CGFloat(70)
    let headerWidth = CGFloat(70)
    
    var sections: Array<VHSection> = Array()
    var sectionsInRect: Array<VHSection> = Array()
    
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
        
        if boundsWidth > boundsHeight {
            scrollDirection = UICollectionViewScrollDirection.Horizontal
        } else {
            scrollDirection = UICollectionViewScrollDirection.Vertical
        }
        
        sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        headerReferenceSize = CGSizeMake(headerWidth, headerHeight)
        itemSize = CGSizeMake(cellWidth, cellHeight)
        
        minimumLineSpacing = CGFloat(10)
        minimumInteritemSpacing = CGFloat(10)
        
        sections.removeAll(keepCapacity: true)
        
        for var i = 0; i < collectionView!.numberOfSections(); ++i {
            let section = VHSection()
            section.index = i
            section.itemsCount = collectionView!.numberOfItemsInSection(i)
            sections.append(section)
            
            section.makeCalculation(self)
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        if scrollDirection == .Horizontal {
            var width: CGFloat = 0
            for section in sections {
                width += section.frame.width
            }
            
            return CGSizeMake(width, collectionView!.bounds.height)
        } else {
            var height: CGFloat = 0
            for section in sections {
                height += section.frame.height
            }
            
            return CGSizeMake(collectionView!.bounds.width, height)
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var result: Array<UICollectionViewLayoutAttributes> = Array()
        
        sectionsInRect = sectionsInRect(rect)
        
        for section in sectionsInRect {
            
            if section.itemsCount == 0 {
                continue
            }
            
            // header
            let headerIndexPath = NSIndexPath(index: section.index)
            let  headerLayoutAttribute = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: headerIndexPath)
            
            if headerLayoutAttribute == nil {
                continue
            }
            
            result.append(headerLayoutAttribute!)
            
            // cells
            let cells = section.cellsInRect(rect)
            
            for cell in cells {
                let cellIndexPath = NSIndexPath(forRow: cell.index, inSection: section.index)
                let cellLayoutAttribute = layoutAttributesForItemAtIndexPath(cellIndexPath)
                
                if cellLayoutAttribute == nil {
                    continue
                }
                
                result.append(cellLayoutAttribute!)
            }
            
        }
        
        return result
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        if indexPath.section < 0 || indexPath.section >= sections.count {
            return nil
        }
        
        let section = sections[indexPath.section]
        
        if section.itemsCount == 0 {
            return nil
        }
        
        let cell = section.cellAtIndex(indexPath.row)
        layoutAttribute.frame = cell.frame
        
        return layoutAttribute
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: indexPath)
        
        if indexPath.section < 0 || indexPath.section >= sections.count {
            return nil
        }
        
        let section = sections[indexPath.section]
        
        if section.itemsCount == 0 {
            return nil
        }
        
        let firstCell = section.firstCell()
        let lastCell = section.lastCell()
        
        if scrollDirection == .Horizontal {
            let xOffset = xContentOffset
            let leftByFirstItem = CGRectGetMinX(firstCell.frame) - sectionInset.left
            let rightByLastItem = CGRectGetMaxX(lastCell.frame) + sectionInset.right
            
            let width = min(rightByLastItem - leftByFirstItem, boundsWidth)
            let left = max(xOffset, leftByFirstItem) - max(xOffset + width - rightByLastItem, 0)
            
            layoutAttribute.frame = CGRectMake(left, 0, width, headerHeight)
            layoutAttribute.zIndex = 1024
            
        } else { // Vertical
            let yOffset = yContentOffset
            let topByFirstItem = CGRectGetMinY(firstCell.frame) - sectionInset.top - headerHeight
            let bottomByLastItem = CGRectGetMaxY(lastCell.frame) + sectionInset.bottom
            
            let top = max(yOffset, topByFirstItem) - max(yOffset + headerHeight - bottomByLastItem, 0)
            
            layoutAttribute.frame = CGRectMake(0, top, boundsWidth, headerHeight)
            layoutAttribute.zIndex = 1024
        }
        
        return layoutAttribute
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: Private functions
    
    private func sectionsInRect(rect: CGRect) -> [VHSection] {
        var result: Array<VHSection> = Array()
        
        for section in sections {
            if CGRectIntersectsRect(rect, section.frame) {
                result.append(section)
            }
        }
        
        return result
    }
}