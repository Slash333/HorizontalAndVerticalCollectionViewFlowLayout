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
        return sectionInset.top + sectionInset.bottom
    }
    
    var horizontalInsets: CGFloat {
        return sectionInset.left + sectionInset.right
    }
    
    var verticalLineSpacing: CGFloat = 0
    var horizontalLineSpacing: CGFloat = 0
    
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
            
            // rowCount - calculate rowCount with minimumInteritemSpacing
            rowCount = Int(contentHeight / (cellHeight + minimumInteritemSpacing))
            rowCount = min(itemsCount, rowCount)
            
            // verticalLineSpacing
            verticalLineSpacing = (contentHeight - cellHeight * CGFloat(rowCount)) / CGFloat(rowCount + 1)
            verticalLineSpacing = max(verticalLineSpacing, minimumInteritemSpacing)
            
            // horizontalLineSpacing
            horizontalLineSpacing = minimumLineSpacing
            
            // rowCount - recalculate rowCount with verticalLineSpacing
            rowCount = Int(contentHeight / (cellHeight + verticalLineSpacing))
            rowCount = min(itemsCount, rowCount)
            
            // col
            colCount = itemsCount / rowCount + (itemsCount % rowCount == 0 ? 0 : 1)
            
            // contentWidth
            contentWidth = CGFloat(colCount) * (cellWidth + horizontalLineSpacing) - (colCount > 0 ? horizontalLineSpacing : 0)
            
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
            
            // colCount - calculate colCount with minimumInteritemSpacing
            colCount = Int(contentWidth / (cellWidth + minimumInteritemSpacing))
            colCount = min(itemsCount, colCount)
            
            // horizontalLineSpacing
            horizontalLineSpacing = (contentWidth - cellWidth * CGFloat(colCount)) / CGFloat(colCount + 1)
            horizontalLineSpacing = max(horizontalLineSpacing, minimumInteritemSpacing)
            
            // verticalLineSpacing
            verticalLineSpacing = minimumLineSpacing
            
            // colCount - recalculate colCount with horizontalLineSpacing
            colCount = Int(contentWidth / (cellWidth + horizontalLineSpacing))
            colCount = min(itemsCount, colCount)
            
            // row
            rowCount = itemsCount / colCount + (itemsCount % colCount == 0 ? 0 : 1)
            
            // contentHeight
            contentHeight = CGFloat(rowCount) * (cellHeight + verticalLineSpacing) - (rowCount > 0 ? verticalLineSpacing : 0)
            
            // frame:
            frame.origin.x = 0
            
            if index == 0 {
                frame.origin.y = 0
            } else {
                let previousSection = collectionFlowLayout.sections[index - 1]
                frame.origin.y  = CGRectGetMaxY(previousSection.frame)
            }
            
            frame.size.height = contentHeight + verticalInsets + headerHeight
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
                if previousCell.row + 1 < rowCount {
                    cell.row = previousCell.row + 1
                    cell.col = previousCell.col
                    
                    var cellFrame = previousCell.frame
                    cellFrame.origin.y += cellHeight + verticalLineSpacing
                    cell.frame = cellFrame
                    
                } else {
                    cell.row = 0
                    cell.col = previousCell.col + 1
                    
                    var cellFrame = previousCell.frame
                    cellFrame.origin.x += cellWidth + horizontalLineSpacing
                    cellFrame.origin.y = sectionInset.top + verticalLineSpacing + headerHeight
                    cell.frame = cellFrame
                }
            } else { // Vertical
                if previousCell.col + 1 < colCount {
                    cell.col = previousCell.col + 1
                    cell.row = previousCell.row
                    
                    var cellFrame = previousCell.frame
                    cellFrame.origin.x += cellWidth + horizontalLineSpacing
                    cell.frame = cellFrame
                    
                } else {
                    cell.col = 0
                    cell.row = previousCell.row + 1
                    
                    var cellFrame = previousCell.frame
                    cellFrame.origin.y += cellHeight + verticalLineSpacing
                    cellFrame.origin.x = sectionInset.left + horizontalLineSpacing
                    cell.frame = cellFrame
                }
            }
            
            result.append(cell)
        }
        
        result.append(lastCell)
        
        return result
    }
    
    func firstCell() -> Cell {
        let cell = Cell()
        
        if scrollDirection == .Horizontal {
            cell.frame = CGRectMake(
                frame.origin.x + sectionInset.left,
                frame.origin.y + sectionInset.top + verticalLineSpacing + headerHeight,
                cellWidth,
                cellHeight)
        } else {
            cell.frame = CGRectMake(
                frame.origin.x + sectionInset.left + horizontalLineSpacing,
                frame.origin.y + sectionInset.top + headerHeight,
                cellWidth,
                cellHeight)
        }
        
        return cell
    }

    
    func firstCellInRect(rect: CGRect) -> Cell {
        let cell = firstCell()
        
        if scrollDirection == .Horizontal {
            for var col = 0; col < colCount; ++col {
                if CGRectIntersectsRect(rect, cell.frame) {
                    cell.col = col
                    cell.index = rowCount * cell.col + cell.row
                    return cell
                }
                
                cell.frame.origin.x += cellWidth + horizontalLineSpacing
            }
        } else { // Vertical
            for var row = 0; row < rowCount; ++row {
                if CGRectIntersectsRect(rect, cell.frame) {
                    cell.row = row
                    cell.index = colCount * cell.row + cell.col
                    return cell
                }
                
                cell.frame.origin.y += cellHeight + verticalLineSpacing
            }
        }
        
        return cell
    }
    
    func lastCell() -> Cell {
        
        let cell = Cell()
        cell.index = itemsCount - 1
        
        if scrollDirection == .Horizontal {
            cell.col = cell.index / rowCount
            cell.row = cell.index % rowCount
            
            cell.frame = CGRectMake(
                frame.origin.x + sectionInset.left + CGFloat(cell.col) * (cellWidth + (cell.col > 1 ? horizontalLineSpacing : 0)),
                frame.origin.y + headerHeight + sectionInset.top + verticalLineSpacing + CGFloat(cell.row) * (cellHeight + verticalLineSpacing),
                cellWidth,
                cellHeight)
            
        } else {
            cell.col = cell.index % colCount
            cell.row = cell.index / colCount
            
            cell.frame = CGRectMake(
                frame.origin.x + sectionInset.left + horizontalLineSpacing + CGFloat(cell.col) * (cellWidth + horizontalLineSpacing),
                frame.origin.y + headerHeight + sectionInset.top + CGFloat(cell.row) * (cellHeight + verticalLineSpacing),
                cellWidth,
                cellHeight)
        }
        
        return cell
    }
    
    func lastCellInRect(rect: CGRect) -> Cell {
        
        let cell = lastCell()
        
        if scrollDirection == .Horizontal {
            for var col = colCount - 1; col >= 0; --col {
                if CGRectIntersectsRect(rect, cell.frame) {
                    cell.col = col
                    cell.index = rowCount * cell.col + cell.row
                    break
                }
                
                cell.frame.origin.x -= cellWidth + horizontalLineSpacing
            }
        } else {
            for var row = rowCount - 1; row >= 0; --row {
                if CGRectIntersectsRect(rect, cell.frame) {
                    cell.row = row
                    cell.index = colCount * cell.row + cell.col
                    break
                }
                
                cell.frame.origin.y -= cellHeight + verticalLineSpacing
            }
        }
        
        return cell
    }
}