//
//  Section.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 9/21/15.
//  Copyright (c) 2015 Igor Ponomarenko. All rights reserved.
//

import Foundation

class Section {
    var itemsCount = 0
    
    var rowCount = 0
    var colCount = 0
    
    var index = 0
    
    var frame = CGRectMake(0, 0, 0, 0)
    var sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
    
    var contentHeight: CGFloat = 0
    var contentWidth: CGFloat = 0
    
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
    
    var minimumLineSpacing = CGFloat(0)
    var minimumInteritemSpacing = CGFloat(0)
    
    var cellHeight = CGFloat(0)
    var cellWidth = CGFloat(0)
    
    var headerHeight = CGFloat(0)
    var headerWidth = CGFloat(0)
    
    var scrollDirection = UICollectionViewScrollDirection.Vertical
    
    func makeCalculation(collectionFlowLayout: CollectionFlowLayout) {
        
        scrollDirection = collectionFlowLayout.scrollDirection
        minimumLineSpacing = collectionFlowLayout.minimumLineSpacing
        minimumInteritemSpacing = collectionFlowLayout.minimumInteritemSpacing
        sectionInset = collectionFlowLayout.sectionInset
        headerWidth = collectionFlowLayout.headerWidth
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
            contentWidth = CGFloat(colCount) * (cellWidth + minimumLineSpacing) - (colCount > 0 ? minimumLineSpacing : 0)
            
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
            contentHeight = CGFloat(rowCount) * (cellHeight + minimumLineSpacing) - (rowCount > 0 ? minimumLineSpacing : 0)
            
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
    
    func cellsInRect(rect: CGRect) -> [Cell] {
        var result: Array<Cell> = Array()
        
        let firstCell = firstCellInRect(rect)
        let lastCell = lastCellInRect(rect)
        
        result.append(firstCell)
        
        for var i = firstCell.index + 1; i <= lastCell.index - 1; ++i {
            let previousCell = result.last!
            let cell = Cell()
            
            cell.index = previousCell.index + 1
            
            if scrollDirection == .Horizontal {
                cell.col = cell.index / rowCount
                cell.row = cell.index % rowCount
                
            } else {
                cell.col = cell.index % colCount
                cell.row = cell.index / colCount
            }
            
            cell.frame = frameForCellInRow(cell.row, col: cell.col)
            result.append(cell)
        }
        
        result.append(lastCell)
        
        return result
    }
    
    func firstCell() -> Cell {
        let cell = Cell()
        cell.frame = frameForCellInRow(cell.row, col: cell.col)
        return cell
    }

    
    func firstCellInRect(rect: CGRect) -> Cell {
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
    
    func lastCell() -> Cell {
        
        let cell = Cell()
        cell.index = max(itemsCount - 1, 0)
        
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
    
    func lastCellInRect(rect: CGRect) -> Cell {
        
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
    
    func frameForCellInRow(row: Int, col: Int) -> CGRect {
        
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