//
//  CollectionFlowLayout.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 19.09.15.
//  Copyright (c) 2015 Igor Ponomarenko. All rights reserved.
//

import Foundation

class CollectionFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: constants
    
    let cellHeight = CGFloat(70)
    let cellWidth = CGFloat(70)
    let headerHeight = CGFloat(70)
    let headerWidth = CGFloat(70)
    
    var sections: Array<Section> = Array()
    var sectionsInRect: Array<Section> = Array()
    
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
            scrollDirection = UICollectionViewScrollDirection.Horizontal
        }
        
        sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        headerReferenceSize = CGSizeMake(headerWidth, headerHeight)
        itemSize = CGSizeMake(cellWidth, cellHeight)
        
        minimumLineSpacing = CGFloat(10)
        minimumInteritemSpacing = CGFloat(10)
        
        sections.removeAll(keepCapacity: true)
        
        for var i = 0; i < collectionView!.numberOfSections(); ++i {
            let section = Section()
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
            
            // header
            let headerIndexPath = NSIndexPath(index: section.index)
            
            let headerLayoutAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: headerIndexPath)
            //let headerLayoutAttribute = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: headerIndexPath)
            
            let firstCell = section.firstCell()
            let lastCell = section.lastCell()
            
            if scrollDirection == .Horizontal {
                let xOffset = xContentOffset
                let leftByFirstItem = CGRectGetMinX(firstCell.frame) - sectionInset.left
                let rightByLastItem = CGRectGetMaxX(lastCell.frame) + sectionInset.right
                
                let width = min(rightByLastItem - leftByFirstItem, boundsWidth)
                let left = max(xOffset, leftByFirstItem) - max(xOffset + width - rightByLastItem, 0)
                
                headerLayoutAttribute.frame = CGRectMake(left, 0, width, headerHeight)
                headerLayoutAttribute.zIndex = 1024
                result.append(headerLayoutAttribute)
                
                // cells
                let cells = section.cellsInRect(rect)
                
                for cell in cells {
                    let cellIndexPath = NSIndexPath(forRow: cell.index, inSection: section.index)
                    let cellLayoutAttribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: cellIndexPath)
                    //let cellLayoutAttribute = layoutAttributesForItemAtIndexPath(cellIndexPath)
                    
                    cellLayoutAttribute.frame = cell.frame
                    result.append(cellLayoutAttribute)
                }
            } else { // Vertical
                let yOffset = yContentOffset
                let topByFirstItem = CGRectGetMinY(firstCell.frame) - sectionInset.top - headerHeight
                let bottomByLastItem = CGRectGetMaxY(lastCell.frame) + sectionInset.bottom
                
                let top = max(yOffset, topByFirstItem) - max(yOffset + headerHeight - bottomByLastItem, 0)
                
                headerLayoutAttribute.frame = CGRectMake(0, top, boundsWidth, headerHeight)
                headerLayoutAttribute.zIndex = 1024
                result.append(headerLayoutAttribute)
                
                // cells
                let cells = section.cellsInRect(rect)
                
                for cell in cells {
                    let cellIndexPath = NSIndexPath(forRow: cell.index, inSection: section.index)
                    let cellLayoutAttribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: cellIndexPath)
                    //let cellLayoutAttribute = layoutAttributesForItemAtIndexPath(cellIndexPath)
                    
                    cellLayoutAttribute.frame = cell.frame
                    result.append(cellLayoutAttribute)
                }
            }
            
        }
        
        return result
    }
    
//    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
//        let layoutAttribute = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
//        return layoutAttribute
//    }
//    
//    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
//        let layoutAttribute = super.layoutAttributesForItemAtIndexPath(indexPath)
//        return layoutAttribute
//    }
    
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