//
//  VHDecorationViewHorizontal.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 12/4/15.
//  Copyright © 2015 Igor Ponomarenko. All rights reserved.
//

import UIKit

class VHDecorationViewHorizontal: VHDecorationView {
    override func initView() {
        super.initView()
        
        addLeftBorderView()
    }
    
    func addLeftBorderView() {
        removeBorderView()
        
        let frame = CGRectMake(bounds.width - VHDecorationView.borderWidth, 0, VHDecorationView.borderWidth, bounds.height)
        let view = UIView(frame: frame)
        view.autoresizingMask = [.FlexibleHeight, .FlexibleLeftMargin]
        view.backgroundColor = UIColor.grayColor()
        view.alpha = 0.9
        addSubview(view)
        
    }
}
