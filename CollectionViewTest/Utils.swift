//
//  Utils.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 9/24/15.
//  Copyright © 2015 Igor Ponomarenko. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    class func maxItemCountInDimension(dimension: CGFloat, minimumInteritemSpacing: CGFloat, itemDimension: CGFloat) -> Int {
        
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
    
    class func minimumInteritemSpacingInDimension(dimension: CGFloat, itemDimension: CGFloat, itemsCount: Int) -> CGFloat {
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