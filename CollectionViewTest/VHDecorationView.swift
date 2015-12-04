//
//  VHDecorationView.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 12/4/15.
//  Copyright © 2015 Igor Ponomarenko. All rights reserved.
//

import UIKit

class VHDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    static let borderWidth = CGFloat(2)
    
    private var borderView: UIView?
    
    func initView() {
        let view = UIView(frame: self.bounds)
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.backgroundColor = UIColor.whiteColor()
        view.alpha = 0.9
        addSubview(view)
    }
    
    func removeBorderView() {
        if borderView != nil {
            borderView!.removeFromSuperview()
            borderView = nil
        }
    }
}
