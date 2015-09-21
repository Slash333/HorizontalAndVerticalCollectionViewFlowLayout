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
    
    func makeCalculation(collectionFlowLayout: CollectionFlowLayout) {
        
        // minimumLineSpacing
        minimumLineSpacing = collectionFlowLayout.minimumLineSpacing
        
        // minimumInteritemSpacing
        minimumInteritemSpacing = collectionFlowLayout.minimumInteritemSpacing
        
        // sectionInset
        sectionInset = collectionFlowLayout.sectionInset
        
        // contentHeight
        contentHeight = collectionFlowLayout.boundsHeight - verticalInsets
        
        // row
        rowCount = Int(contentHeight / (cellHeight + minimumInteritemSpacing))
        
        if itemsCount < rowCount {
            rowCount = itemsCount
        }
        
        // verticalLineSpacing
        
        verticalLineSpacing = (contentHeight - cellHeight * CGFloat(rowCount)) / CGFloat(rowCount + 1)
        
        if verticalLineSpacing < minimumInteritemSpacing {
            verticalLineSpacing = minimumInteritemSpacing
        }
        
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
                cellFrame.origin.y = sectionInset.top + verticalLineSpacing
                cell.frame = cellFrame
            }
            
            result.append(cell)
        }
        
        result.append(lastCell)
        
        return result
    }
    
    private func firstCellInRect(rect: CGRect) -> Cell {
        
        let x = rect.origin.x
        
        let cell = Cell()
        
        cell.frame = CGRectMake(
            frame.origin.x + sectionInset.left,
            frame.origin.y + sectionInset.top + verticalLineSpacing,
            cellWidth,
            cellHeight)
        
        for var col = 0; col < colCount; ++col {
            if CGRectIntersectsRect(rect, cell.frame) {
                cell.col = col
                cell.index = rowCount * cell.col + cell.row
                return cell
            }
            
            cell.frame.origin.x += cellWidth + minimumLineSpacing
        }
        
        return cell
    }
    
    private func lastCellInRect(rect: CGRect) -> Cell {
        
        let cell = Cell()
        cell.col = colCount - 1
        cell.row = rowCount - 1
        cell.index = rowCount * cell.col + cell.row
        
        cell.frame = CGRectMake(
            frame.origin.x + sectionInset.left + CGFloat(cell.col) * (cellWidth + minimumLineSpacing),
            frame.origin.y + sectionInset.top + verticalLineSpacing + CGFloat(cell.row) * (cellHeight + verticalLineSpacing),
            cellWidth,
            cellHeight)
        
        for var col = colCount - 1; col >= 0; --col {
            if CGRectIntersectsRect(rect, cell.frame) {
                cell.col = col
                cell.index = rowCount * cell.col + cell.row
                break
            }
            
            cell.frame.origin.x -= cellWidth + minimumLineSpacing
        }
        
        if cell.index >= itemsCount {
            cell.index = itemsCount - 1
            cell.row = cell.index % rowCount
            cell.frame.origin.y =
                frame.origin.y + sectionInset.top + verticalLineSpacing + CGFloat(cell.row) * (cellHeight + verticalLineSpacing)
        }
        
        return cell
    }
}