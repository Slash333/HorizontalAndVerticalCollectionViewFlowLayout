//
//  VHDecorationViewHorizontal.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 12/4/15.
//  Copyright © 2015 Igor Ponomarenko. All rights reserved.
//

import UIKit

class VHDecorationViewVertical: VHDecorationView {
    
    override func initView() {
        super.initView()
        
        addBottomBorderView()
    }
    
    func addBottomBorderView() {
        removeBorderView()
        
        let frame = CGRectMake(0, bounds.height - VHDecorationView.borderWidth, bounds.width, VHDecorationView.borderWidth)
        let view = UIView(frame: frame)
        view.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        view.backgroundColor = UIColor.grayColor()
        view.alpha = 0.9
        addSubview(view)
        
    }
}
