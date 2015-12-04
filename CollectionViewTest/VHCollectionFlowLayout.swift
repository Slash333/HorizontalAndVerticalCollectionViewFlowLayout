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
    
    var isFirstSectionAlwaysVisible = true
    
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
    
    var horizontalContentInset: CGFloat {
        return leftContentInset + rightContentInset
    }
    
    var verticalContentInset: CGFloat {
        return topContentInset + bottomContentInset
    }
    
    var leftContentInset: CGFloat {
        return self.collectionView!.contentInset.left
    }
    
    var topContentInset: CGFloat {
        return self.collectionView!.contentInset.top
    }
    
    var rightContentInset: CGFloat {
        return self.collectionView!.contentInset.right
    }
    
    var bottomContentInset: CGFloat {
        return self.collectionView!.contentInset.bottom
    }
    
    // MARK: Overrides
    
    override func prepareLayout() {
        super.prepareLayout()
        
        if boundsWidth > boundsHeight {
            scrollDirection = UICollectionViewScrollDirection.Horizontal
        } else {
            scrollDirection = UICollectionViewScrollDirection.Vertical
        }
        
        collectionView!.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
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
        var width: CGFloat = 0
        var height: CGFloat = 0
        if scrollDirection == .Horizontal {
            for section in sections {
                width += section.frame.width
                height = max(section.frame.height, height)
            }
        } else {
            for section in sections {
                width = max(section.frame.width, width)
                height += section.frame.height
            }
        }
        return CGSizeMake(width, height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var result: Array<UICollectionViewLayoutAttributes> = Array()
        
        sectionsInRect = sectionsInRect(rect)
        
        for section in sectionsInRect {
            
            if section.itemsCount == 0 {
                continue
            }
            
            // add decoration view
            if isFirstSectionAlwaysVisible {
                if section.index == 0 {
                    let decorationViewIndexPath = NSIndexPath(index: section.index)
                    let decorationViewKind = scrollDirection == .Horizontal ? "VHDecorationViewHorizontal" : "VHDecorationViewVertical"
                    let decorationView = layoutAttributesForDecorationViewOfKind(decorationViewKind, atIndexPath: decorationViewIndexPath)
                    
                    if decorationView != nil {
                        result.append(decorationView!)
                    }
                }
            }
            
            // add header view
            let headerIndexPath = NSIndexPath(index: section.index)
            let  headerLayoutAttribute = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: headerIndexPath)
            
            if headerLayoutAttribute == nil {
                continue
            }
            
            result.append(headerLayoutAttribute!)
            
            // add cells cells
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
        
        if section.index == 0 {
            layoutAttribute.zIndex = 7
        } else {
            layoutAttribute.zIndex = 1
        }
        
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
            
            let leftByFirstItem = section.frame.origin.x
            var rightByLastItem = CGRectGetMaxX(lastCell.frame) + sectionInset.right
            
            if let collectionView = self.collectionView {
                if let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
                    if let headerSize = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: indexPath.section) {
                        if (rightByLastItem - leftByFirstItem) < headerSize.width {
                            rightByLastItem = headerSize.width + leftByFirstItem
                        }
                    }
                }
            }
            
            var width = min(rightByLastItem - leftByFirstItem, boundsWidth - horizontalContentInset)
            
            var leftEdge = xContentOffset + leftContentInset
            
            if isFirstSectionAlwaysVisible {
                if section.index > 0 {
                    let firstSection = sections[0]
                    leftEdge += firstSection.frame.width
                    width -= firstSection.frame.width
                }
            }
            
            let left = max(leftEdge, leftByFirstItem) - max(leftEdge + width - rightByLastItem, 0)
            
            layoutAttribute.frame = CGRectMake(left, 0, width, headerHeight)
            
        } else { // Vertical
            
            let topByFirstItem = CGRectGetMinY(firstCell.frame) - sectionInset.top - headerHeight
            let bottomByLastItem = CGRectGetMaxY(lastCell.frame) + sectionInset.bottom
            
            let width = boundsWidth - horizontalContentInset
            
            
            var topEdge = yContentOffset + topContentInset
            
            if isFirstSectionAlwaysVisible {
                if section.index > 0 {
                    let firstSection = sections[0]
                    topEdge += firstSection.frame.height
                }
            }
            
            let top = max(topEdge, topByFirstItem) - max(topEdge + headerHeight - bottomByLastItem, 0)
            
            layoutAttribute.frame = CGRectMake(0, top, width, headerHeight)
        }
        
        if section.index == 0 {
            layoutAttribute.zIndex = 10
        } else {
            layoutAttribute.zIndex = 5
        }
        
        return layoutAttribute
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, withIndexPath: indexPath)
        
        if isFirstSectionAlwaysVisible {
            let firstSection = sections[0]
            layoutAttribute.frame = firstSection.frame
            layoutAttribute.zIndex = 6
        }
        
        return layoutAttribute
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: - Helpers
    
    func decorateViewWidth() -> CGFloat {
        if isFirstSectionAlwaysVisible {
            return VHDecorationView.borderWidth
        }
    
        return CGFloat(0)
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