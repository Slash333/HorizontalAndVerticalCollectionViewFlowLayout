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
    
    var hotizontalInsets: CGFloat {
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
        // scrollDirection
        scrollDirection = collectionFlowLayout.scrollDirection
        
        // minimumLineSpacing
        minimumLineSpacing = collectionFlowLayout.minimumLineSpacing
        
        // minimumInteritemSpacing
        minimumInteritemSpacing = collectionFlowLayout.minimumInteritemSpacing
        
        // sectionInset
        sectionInset = collectionFlowLayout.sectionInset
        
        // headerWidth
        headerHeight = collectionFlowLayout.headerWidth
        
        // headerHeight
        headerHeight = collectionFlowLayout.headerHeight
        
        // cellHeight
        cellHeight = collectionFlowLayout.cellHeight
        
        // cellWidth
        cellWidth = collectionFlowLayout.cellWidth
        
        // contentHeight
        contentHeight = collectionFlowLayout.boundsHeight - verticalInsets - headerHeight
        
        // rowCount - calculate rowCount with minimumInteritemSpacing
        rowCount = Int(contentHeight / (cellHeight + minimumInteritemSpacing))
        rowCount = min(itemsCount, rowCount)
        
        // verticalLineSpacing
        
        verticalLineSpacing = (contentHeight - cellHeight * CGFloat(rowCount)) / CGFloat(rowCount + 1)
        
        verticalLineSpacing = max(verticalLineSpacing, minimumInteritemSpacing)
        
        // rowCount - recalculate rowCount with verticalLineSpacing
        rowCount = Int(contentHeight / (cellHeight + verticalLineSpacing))
        rowCount = min(itemsCount, rowCount)
        
        // col
        colCount = itemsCount / rowCount + (itemsCount % rowCount == 0 ? 0 : 1)
        
        // contentWidth
        contentWidth = CGFloat(colCount) * (cellWidth + minimumLineSpacing) - (colCount > 0 ? minimumLineSpacing : 0)
        
        // frame:
        
        if index == 0 {
            frame.origin.x = 0
        } else {
            let previousSection = collectionFlowLayout.sections[index - 1]
            frame.origin.x  = previousSection.frame.origin.x + previousSection.frame.size.width
        }
        
        frame.origin.y = 0
        frame.size.height = collectionFlowLayout.boundsHeight
        frame.size.width = contentWidth + hotizontalInsets
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
                if previousCell.row + 1 < rowCount{
                    cell.row = previousCell.row + 1
                    cell.col = previousCell.col
                    
                    var cellFrame = previousCell.frame
                    cellFrame.origin.y += cellHeight + verticalLineSpacing
                    cell.frame = cellFrame
                    
                } else {
                    cell.row = 0
                    cell.col = previousCell.col + 1
                    
                    var cellFrame = previousCell.frame
                    cellFrame.origin.x += cellWidth + minimumLineSpacing
                    cellFrame.origin.y = sectionInset.top + verticalLineSpacing + headerHeight
                    cell.frame = cellFrame
                }
            } else {
                // !!!
                if previousCell.row + 1 < rowCount{
                    cell.row = previousCell.row + 1
                    cell.col = previousCell.col
                    
                    var cellFrame = previousCell.frame
                    cellFrame.origin.y += cellHeight + verticalLineSpacing
                    cell.frame = cellFrame
                    
                } else {
                    cell.row = 0
                    cell.col = previousCell.col + 1
                    
                    var cellFrame = previousCell.frame
                    cellFrame.origin.x += cellWidth + minimumLineSpacing
                    cellFrame.origin.y = sectionInset.top + verticalLineSpacing + headerHeight
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
            // !!!
            cell.frame = CGRectMake(
                frame.origin.x + sectionInset.left,
                frame.origin.y + sectionInset.top + verticalLineSpacing + headerHeight,
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
                
                cell.frame.origin.x += cellWidth + minimumLineSpacing
            }
        } else {
            // !!!
            for var col = 0; col < colCount; ++col {
                if CGRectIntersectsRect(rect, cell.frame) {
                    cell.col = col
                    cell.index = rowCount * cell.col + cell.row
                    return cell
                }
                
                cell.frame.origin.x += cellWidth + minimumLineSpacing
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
                frame.origin.x + sectionInset.left + CGFloat(cell.col) * (cellWidth + (cell.col > 1 ? minimumLineSpacing : 0)),
                frame.origin.y + sectionInset.top + verticalLineSpacing + headerHeight + CGFloat(cell.row) * (cellHeight + verticalLineSpacing),
                cellWidth,
                cellHeight)
        } else {
            // !!!
            cell.col = cell.index % colCount
            cell.row = cell.index / colCount
            
            cell.frame = CGRectMake(
                frame.origin.x + sectionInset.left + CGFloat(cell.col) * (cellWidth + (cell.col > 1 ? minimumLineSpacing : 0)),
                frame.origin.y + sectionInset.top + verticalLineSpacing + headerHeight + CGFloat(cell.row) * (cellHeight + verticalLineSpacing),
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
                
                cell.frame.origin.x -= cellWidth + minimumLineSpacing
            }
        } else {
            // !!!
            for var col = colCount - 1; col >= 0; --col {
                if CGRectIntersectsRect(rect, cell.frame) {
                    cell.col = col
                    cell.index = rowCount * cell.col + cell.row
                    break
                }
                
                cell.frame.origin.x -= cellWidth + minimumLineSpacing
            }
        }
        
        return cell
    }
}