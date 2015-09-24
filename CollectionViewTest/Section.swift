//
//  Section.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 9/21/15.
//  Copyright (c) 2015 Igor Ponomarenko. All rights reserved.
//

import Foundation
import UIKit

class Section {
    
    // MARK: Private fields
    
    private (set) var rowCount = 0
    private (set) var colCount = 0
    
    private (set) var frame = CGRectMake(0, 0, 0, 0)
    private (set) var sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
    
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
    
    var verticalInsets: CGFloat {
        if itemsCount > 0 {
            return sectionInset.top + sectionInset.bottom
        } else {
            return CGFloat(0)
        }
    }
    
    var horizontalInsets: CGFloat {
        if itemsCount > 0 {
            return sectionInset.left + sectionInset.right
        } else {
            return CGFloat(0)
        }
    }
    
    func makeCalculation(collectionFlowLayout: CollectionFlowLayout) {
        
        scrollDirection = collectionFlowLayout.scrollDirection
        minimumLineSpacing = collectionFlowLayout.minimumLineSpacing
        minimumInteritemSpacing = collectionFlowLayout.minimumInteritemSpacing
        sectionInset = collectionFlowLayout.sectionInset
        headerHeight = collectionFlowLayout.headerHeight
        cellHeight = collectionFlowLayout.cellHeight
        cellWidth = collectionFlowLayout.cellWidth
        
        if scrollDirection == .Horizontal {
            // contentHeight
            contentHeight = collectionFlowLayout.boundsHeight - verticalInsets - headerHeight
            
            // calculate new minimumInteritemSpacing
            let maxRowCount = Utils.maxItemCountInDimension(contentHeight, minimumInteritemSpacing: minimumInteritemSpacing, itemDimension: cellHeight)
            let calculatedMinimumInteritemSpacing = Utils.minimumInteritemSpacingInDimension(contentHeight, itemDimension: cellHeight, itemsCount: maxRowCount)
            minimumInteritemSpacing = max(calculatedMinimumInteritemSpacing, minimumInteritemSpacing)

            // rowCount
            rowCount = min(itemsCount, maxRowCount)
            
            // colCount
            if rowCount > 0 {
                colCount = itemsCount / rowCount + (itemsCount % rowCount == 0 ? 0 : 1)
            }
            
            // contentWidth
            contentWidth = CGFloat(colCount) * cellWidth + CGFloat(max(colCount - 1, 0)) * minimumLineSpacing
            
            // frame:
            if index == 0 {
                frame.origin.x = 0
            } else {
                let previousSection = collectionFlowLayout.sections[index - 1]
                frame.origin.x  = CGRectGetMaxX(previousSection.frame)
            }
            
            frame.origin.y = 0
            frame.size.height = collectionFlowLayout.boundsHeight
            frame.size.width = contentWidth + horizontalInsets
            
        } else {
            // contentWidth
            contentWidth = collectionFlowLayout.boundsWidth - horizontalInsets
            
            // calculate new minimumInteritemSpacing
            let maxColCount = Utils.maxItemCountInDimension(contentWidth, minimumInteritemSpacing: minimumInteritemSpacing, itemDimension: cellWidth)
            let calculatedMinimumInteritemSpacing = Utils.minimumInteritemSpacingInDimension(contentWidth, itemDimension: cellWidth, itemsCount: maxColCount)
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
            
            if index == 0 {
                frame.origin.y = 0
            } else {
                let previousSection = collectionFlowLayout.sections[index - 1]
                frame.origin.y  = CGRectGetMaxY(previousSection.frame)
            }
            
            frame.size.height = contentHeight + verticalInsets + (itemsCount > 0 ? headerHeight : 0)
            frame.size.width = collectionFlowLayout.boundsWidth
        }
    }
    
    func cellAtIndex(index: Int) -> Cell {
        let cell = Cell()
        cell.index = index
        
        if scrollDirection == .Horizontal {
            cell.col = cell.index / rowCount
            cell.row = cell.index % rowCount
            
        } else {
            cell.col = cell.index % colCount
            cell.row = cell.index / colCount
        }
        
        cell.frame = frameForCellInRow(cell.row, col: cell.col)
        
        return cell
    }
    
    func firstCell() -> Cell {
        return cellAtIndex(0)
    }
    
    func lastCell() -> Cell {
        return cellAtIndex(max(itemsCount - 1, 0))
    }
    
    func cellsInRect(rect: CGRect) -> [Cell] {
        var result: Array<Cell> = Array()
        
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
    
    private func firstCellInRect(rect: CGRect) -> Cell {
        let cell = firstCell()
        
        if scrollDirection == .Horizontal {
            
            for var col = 0; col < colCount; ++col {
                if CGRectIntersectsRect(rect, cell.frame) {
                    return cell
                }
                
                cell.col = col
                cell.index = rowCount * cell.col + cell.row
                cell.frame = frameForCellInRow(cell.row, col: cell.col)
            }
            
        } else {
            for var row = 0; row < rowCount; ++row {
                if CGRectIntersectsRect(rect, cell.frame) {
                    return cell
                }
                
                cell.row = row
                cell.index = colCount * cell.row + cell.col
                cell.frame = frameForCellInRow(cell.row, col: cell.col)
            }
        }
        
        return cell
    }
    
    private func lastCellInRect(rect: CGRect) -> Cell {
        
        let cell = lastCell()
        
        if scrollDirection == .Horizontal {
            
            for var col = colCount - 1; col >= 0; --col {
                if CGRectIntersectsRect(rect, cell.frame) {
                    break
                }
                
                cell.col = max(col - 1, 0)
                cell.row = max(cell.row, rowCount - 1)
                cell.index = rowCount * cell.col + cell.row
                cell.frame = frameForCellInRow(cell.row, col: cell.col)
            }
            
        } else {
            for var row = rowCount - 1; row >= 0; --row {
                if CGRectIntersectsRect(rect, cell.frame) {
                    break
                }
                
                cell.row = row
                cell.col = max(cell.col, colCount - 1)
                cell.index = colCount * cell.row + cell.col
                cell.frame = frameForCellInRow(cell.row, col: cell.col)
            }
        }
        
        return cell
    }
    
    private func frameForCellInRow(row: Int, col: Int) -> CGRect {
        
        let xAdditionalItemsSpace = scrollDirection == .Horizontal ? minimumLineSpacing : minimumInteritemSpacing
        let yAdditionalItemsSpace = scrollDirection == .Horizontal ? minimumInteritemSpacing : minimumLineSpacing
        
        let x = frame.origin.x +
            sectionInset.left +
            CGFloat(col) * (cellWidth + xAdditionalItemsSpace )
        
        let y = frame.origin.y +
            headerHeight +
            sectionInset.top +
            CGFloat(row) * (cellHeight + yAdditionalItemsSpace)
        
        return CGRectMake(x, y, cellWidth, cellHeight)
    }
}