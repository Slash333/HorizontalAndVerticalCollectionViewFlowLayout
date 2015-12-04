//
//  Section.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 9/21/15.
//  Copyright (c) 2015 Igor Ponomarenko. All rights reserved.
//

import Foundation
import UIKit

class VHSection {
    
    // MARK: Private fields
    
    var bottomInset = CGFloat(0)
    var leftInset = CGFloat(0)
    
    private (set) var rowCount = 0
    private (set) var colCount = 0
    
    private (set) var frame = CGRectMake(0, 0, 0, 0)
    private (set) var sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
    private (set) var contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    
    private (set) var contentHeight: CGFloat = 0
    private (set) var contentWidth: CGFloat = 0
    
    private (set) var minimumLineSpacing = CGFloat(0)
    private (set) var minimumInteritemSpacing = CGFloat(0)
    
    private (set) var cellHeight = CGFloat(0)
    private (set) var cellWidth = CGFloat(0)
    
    private (set) var headerHeight = CGFloat(0)
    
    private (set) var scrollDirection = UICollectionViewScrollDirection.Vertical
    
    // MARK: Properties
    
    var index = 0
    var itemsCount = 0
    
    var verticalSectionInsets: CGFloat {
        if itemsCount > 0 {
            return sectionInset.top + sectionInset.bottom
        } else {
            return CGFloat(0)
        }
    }
    
    var horizontalSectionInsets: CGFloat {
        if itemsCount > 0 {
            return sectionInset.left + sectionInset.right
        } else {
            return CGFloat(0)
        }
    }
    
    var verticalContentInsets: CGFloat {
        if itemsCount > 0 {
            return contentInset.top + contentInset.bottom
        } else {
            return CGFloat(0)
        }
    }
    
    var horizontalContentInsets: CGFloat {
        if itemsCount > 0 {
            return contentInset.left + contentInset.right
        } else {
            return CGFloat(0)
        }
    }
    
    func makeCalculation(collectionFlowLayout: VHCollectionFlowLayout) {
        
        scrollDirection = collectionFlowLayout.scrollDirection
        minimumLineSpacing = collectionFlowLayout.minimumLineSpacing
        minimumInteritemSpacing = collectionFlowLayout.minimumInteritemSpacing
        sectionInset = collectionFlowLayout.sectionInset
        headerHeight = collectionFlowLayout.headerHeight
        cellHeight = collectionFlowLayout.cellHeight
        cellWidth = collectionFlowLayout.cellWidth
        
        if collectionFlowLayout.collectionView != nil {
            contentInset = collectionFlowLayout.collectionView!.contentInset
        }
        
        if scrollDirection == .Horizontal {
            // contentHeight
            contentHeight = collectionFlowLayout.boundsHeight - verticalSectionInsets - verticalContentInsets - headerHeight
            
            // calculate new minimumInteritemSpacing
            let maxRowCount = maxItemCountInDimension(contentHeight, minimumInteritemSpacing: minimumInteritemSpacing, itemDimension: cellHeight)
            let calculatedMinimumInteritemSpacing = minimumInteritemSpacingInDimension(contentHeight, itemDimension: cellHeight, itemsCount: maxRowCount)
            minimumInteritemSpacing = max(calculatedMinimumInteritemSpacing, minimumInteritemSpacing)

            // rowCount
            rowCount = min(itemsCount, maxRowCount)
            
            // colCount
            if rowCount > 0 {
                colCount = itemsCount / rowCount + (itemsCount % rowCount == 0 ? 0 : 1)
            }
            
            // contentWidth
            contentWidth = CGFloat(colCount) * cellWidth + CGFloat(max(colCount - 1, 0)) * minimumLineSpacing
            
            if let collectionView = collectionFlowLayout.collectionView {
                if let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
                    if let headerSize = delegate.collectionView?(collectionView, layout: collectionFlowLayout, referenceSizeForHeaderInSection: index) {
                        if contentWidth < headerSize.width {
                            contentWidth = headerSize.width
                        }
                    }
                }
            }
            
            // frame:
            if (collectionFlowLayout.isFirstSectionAlwaysVisible) {
                
                if index == 0 {
                    frame.origin.x = collectionFlowLayout.xContentOffset + contentInset.left
                } else {
                    let previousSection = collectionFlowLayout.sections[index - 1]
                    if index == 1 {
                        frame.origin.x  = CGRectGetMaxX(previousSection.frame) - collectionFlowLayout.xContentOffset - contentInset.left
                    } else {
                        frame.origin.x  = CGRectGetMaxX(previousSection.frame)
                    }
                }
                
            } else {
                
                if index == 0 {
                    frame.origin.x = 0
                } else {
                    let previousSection = collectionFlowLayout.sections[index - 1]
                    frame.origin.x  = CGRectGetMaxX(previousSection.frame)
                }
                
            }
            
            frame.origin.y = 0
            frame.size.height = collectionFlowLayout.boundsHeight - verticalContentInsets
            frame.size.width = contentWidth + horizontalSectionInsets
            
            leftInset = 0
            
            if collectionFlowLayout.isFirstSectionAlwaysVisible && index == 0 {
                leftInset = collectionFlowLayout.decorateViewWidth()
                frame.size.width += leftInset
            }
            
        } else {
            // contentWidth
            contentWidth = collectionFlowLayout.boundsWidth - horizontalSectionInsets - horizontalContentInsets
            
            // calculate new minimumInteritemSpacing
            let maxColCount = maxItemCountInDimension(contentWidth, minimumInteritemSpacing: minimumInteritemSpacing, itemDimension: cellWidth)
            let calculatedMinimumInteritemSpacing = minimumInteritemSpacingInDimension(contentWidth, itemDimension: cellWidth, itemsCount: maxColCount)
            minimumInteritemSpacing = max(calculatedMinimumInteritemSpacing, minimumInteritemSpacing)
            
            // colCount
            colCount = min(itemsCount, maxColCount)
            
            // rowCount
            if colCount > 0 {
                rowCount = itemsCount / colCount + (itemsCount % colCount == 0 ? 0 : 1)
            }
            
            // contentHeight
            
            contentHeight = CGFloat(rowCount) * cellHeight + CGFloat(max(rowCount - 1, 0)) * minimumLineSpacing
            
            // frame:
            frame.origin.x = 0
            
            
            if (collectionFlowLayout.isFirstSectionAlwaysVisible) {
                
                if index == 0 {
                    frame.origin.y = collectionFlowLayout.yContentOffset + contentInset.top
                } else {
                    let previousSection = collectionFlowLayout.sections[index - 1]
                    if index == 1 {
                        frame.origin.y  = CGRectGetMaxY(previousSection.frame) - collectionFlowLayout.yContentOffset - contentInset.top
                    } else {
                        frame.origin.y  = CGRectGetMaxY(previousSection.frame)
                    }
                }
                
            } else {
                
                if index == 0 {
                    frame.origin.y = CGFloat(0)
                } else {
                    let previousSection = collectionFlowLayout.sections[index - 1]
                    frame.origin.y  = CGRectGetMaxY(previousSection.frame)
                }
                
            }
            
            frame.size.height = contentHeight + verticalSectionInsets + (itemsCount > 0 ? headerHeight : 0)
            bottomInset = 0

            if collectionFlowLayout.isFirstSectionAlwaysVisible && index == 0 {
                bottomInset = collectionFlowLayout.decorateViewWidth()
                frame.size.height += bottomInset
            }
            
            frame.size.width = collectionFlowLayout.boundsWidth - horizontalContentInsets
        }
    }
    
    func cellAtIndex(index: Int) -> VHCell {
        let cell = VHCell()
        cell.index = index
        
        if scrollDirection == .Horizontal {
            if rowCount > 0 {
                cell.col = cell.index / rowCount
                cell.row = cell.index % rowCount
            }
        } else {
            if colCount > 0 {
                cell.col = cell.index % colCount
                cell.row = cell.index / colCount
            }
        }
        
        cell.frame = frameForCellInRow(cell.row, col: cell.col)
        
        return cell
    }
    
    func firstCell() -> VHCell {
        return cellAtIndex(0)
    }
    
    func lastCell() -> VHCell {
        return cellAtIndex(max(itemsCount - 1, 0))
    }
    
    func cellsInRect(rect: CGRect) -> [VHCell] {
        var result: Array<VHCell> = Array()
        
        let firstCell = firstCellInRect(rect)
        let lastCell = lastCellInRect(rect)
        
        result.append(firstCell)
        
        for var i = firstCell.index + 1; i <= lastCell.index - 1; ++i {
            let previousCell = result.last!
            let cell = cellAtIndex(previousCell.index + 1)
            result.append(cell)
        }
        
        result.append(lastCell)
        
        return result
    }
    
    // MARK: Privte functions
    
    private func firstCellInRect(rect: CGRect) -> VHCell {
        let cell = firstCell()
        
        if scrollDirection == .Horizontal {
            
            var initCol = 0
            let xWidth = CGRectGetMinX(rect) - CGRectGetMinX(frame) + sectionInset.left
            let itemFullWidth = cellWidth + minimumLineSpacing
            
            if xWidth > itemFullWidth && itemFullWidth > 0 {
                let xCount = Int(xWidth / itemFullWidth)
                initCol = max(initCol + xCount, 0)
                initCol = min(initCol, colCount - 1)
            }
            
            for var col = initCol; col < colCount; ++col {
                if cell.col != col {
                    cell.col = col
                    cell.index = rowCount * cell.col + cell.row
                    cell.frame = frameForCellInRow(cell.row, col: cell.col)
                }
                
                if CGRectIntersectsRect(rect, cell.frame) ||
                    CGRectContainsRect(rect, cell.frame) {
                    return cell
                }
            }
            
        } else {
            
            var initRow = 0
            let xHeight = CGRectGetMinY(rect) - CGRectGetMinY(frame) + sectionInset.top - contentInset.top
            let itemFullHeight = cellHeight + minimumLineSpacing
            
            if xHeight > itemFullHeight && itemFullHeight > 0 {
                let xCount = Int(xHeight / itemFullHeight)
                initRow = max(initRow + xCount, 0)
                initRow = min(initRow, rowCount - 1)
            }
            
            for var row = initRow; row < rowCount; ++row {
                if cell.row != row {
                    cell.row = row
                    cell.index = colCount * cell.row + cell.col
                    cell.frame = frameForCellInRow(cell.row, col: cell.col)
                }
                
                if CGRectIntersectsRect(rect, cell.frame) {
                    return cell
                }
            }
        }
        
        return cell
    }
    
    
//    private sectionContentWidth() -> CGFloat {
//    }
    
    private func lastCellInRect(rect: CGRect) -> VHCell {
        
        let cell = lastCell()
        
        if scrollDirection == .Horizontal {
            var initCol = colCount - 1
            
            let xWidth = CGRectGetMaxX(frame) - CGRectGetMaxX(rect) - sectionInset.right
            let itemFullWidth = cellWidth + minimumLineSpacing
            
            if xWidth > itemFullWidth && itemFullWidth > 0 {
                let xCount = Int(xWidth / itemFullWidth)
                initCol -= xCount
                initCol = max(0, initCol)
                initCol = min(initCol, colCount - 1)
            }
            
            for var col = initCol; col >= 0; --col {
                if cell.col != col {
                    cell.col = col
                    cell.row = max(cell.row, rowCount - 1)
                    cell.index = rowCount * cell.col + cell.row
                    cell.frame = frameForCellInRow(cell.row, col: cell.col)
                }
                
                if CGRectIntersectsRect(rect, cell.frame) ||
                    CGRectContainsRect(rect, cell.frame) {
                    break
                }
            }
            
        } else {
            
            var initRow = rowCount - 1
            let xHeight = CGRectGetMaxY(frame) - CGRectGetMaxY(rect) - sectionInset.bottom
            let itemFullHeight = cellHeight + minimumLineSpacing
            
            if xHeight > itemFullHeight && itemFullHeight > 0 {
                let xCount = Int(xHeight / itemFullHeight)
                initRow -= xCount
                initRow = max(initRow, 0)
                initRow = min(initRow, rowCount - 1)
            }
            
            for var row = initRow; row >= 0; --row {
                if cell.row != row {
                    cell.row = row
                    cell.col = max(cell.col, colCount - 1)
                    cell.index = colCount * cell.row + cell.col
                    cell.frame = frameForCellInRow(cell.row, col: cell.col)
                }
                
                if CGRectIntersectsRect(rect, cell.frame) {
                    break
                }
            }
        }
        
        return cell
    }
    
    private func frameForCellInRow(row: Int, col: Int) -> CGRect {
        
        let xAdditionalItemsSpace = scrollDirection == .Horizontal ? minimumLineSpacing : minimumInteritemSpacing
        let yAdditionalItemsSpace = scrollDirection == .Horizontal ? minimumInteritemSpacing : minimumLineSpacing
        
        contentWidth = CGFloat(colCount) * cellWidth + CGFloat(max(colCount - 1, 0)) * xAdditionalItemsSpace
        
        let sectionContentWidth = frame.size.width - sectionInset.left - sectionInset.right - leftInset
        
        // if header width > than content width
        // with offset we will align content on center horizontally
        let offset = (contentWidth < sectionContentWidth) ? (sectionContentWidth - contentWidth) / 2 : CGFloat(0)
        
        let x = frame.origin.x +
            (offset == 0 ? sectionInset.left : offset) +
            CGFloat(col) * (cellWidth + xAdditionalItemsSpace )
        
        let y = frame.origin.y +
            headerHeight +
            sectionInset.top +
            CGFloat(row) * (cellHeight + yAdditionalItemsSpace)
        
        return CGRectMake(x, y, cellWidth, cellHeight)
    }
    
    // MARK: helpers
    
    private func maxItemCountInDimension(dimension: CGFloat, minimumInteritemSpacing: CGFloat, itemDimension: CGFloat) -> Int {
        
        var result = 0
        
        if dimension <= 0 || itemDimension <= 0 || itemDimension > dimension{
            return result
        }
        
        result = Int(dimension / itemDimension)
        
        if result == 1 {
            return result
        }
        
        // items count is greater than one or equal to one (result >= 1)
        
        result = Int(dimension + minimumInteritemSpacing) / Int(itemDimension + minimumInteritemSpacing)
        
        return result
    }
    
    private func minimumInteritemSpacingInDimension(dimension: CGFloat, itemDimension: CGFloat, itemsCount: Int) -> CGFloat {
        var result: CGFloat = 0
        
        if dimension <= 0 || itemDimension <= 0 || itemDimension > dimension{
            return result
        }
        
        if itemsCount > 1 {
            let itemsDimension = CGFloat(itemsCount) * itemDimension
            result = (dimension - itemsDimension) / CGFloat(itemsCount - 1)
        }
        
        return result
    }
}