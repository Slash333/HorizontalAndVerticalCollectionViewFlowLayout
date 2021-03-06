//
//  CollectionViewController.swift
//  CollectionViewTest
//
//  Created by Igor Ponomarenko on 22.07.15.
//  Copyright (c) 2015 Igor Ponomarenko. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"
let reuseHeaderIdentifier = "Header"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind:UICollectionElementKindSectionHeader , withReuseIdentifier: reuseHeaderIdentifier)
        
        collectionView?.delegate = self
        collectionView?.collectionViewLayout = VHCollectionFlowLayout()
        
        collectionView!.collectionViewLayout.registerClass(VHDecorationViewHorizontal.self, forDecorationViewOfKind: "VHDecorationViewHorizontal")
        collectionView!.collectionViewLayout.registerClass(VHDecorationViewVertical.self, forDecorationViewOfKind: "VHDecorationViewVertical")
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 3
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        if section == 0 {
            return 6
        }
        return 50
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) 
    
        // Configure the cell
    
        cell.backgroundColor = UIColor.greenColor()
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.brownColor().CGColor
        
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = "\(indexPath.row)" + " - \(indexPath.section)"
        } else {
            let label = UILabel(frame: CGRectMake(3, 5, 60, 30))
            label.text = "\(indexPath.row)" + " - \(indexPath.section)"
            label.tag = 1
            cell.addSubview(label)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, forIndexPath: indexPath) 
        
        header.backgroundColor = UIColor.redColor()
        header.layer.borderWidth = 2
        header.layer.borderColor = UIColor.blueColor().CGColor
        
        if let label = header.viewWithTag(1) as? UILabel {
            label.text = "\(indexPath.section)"
        } else {
            let label = UILabel(frame: CGRectMake(5, 5, 30, 30))
            label.text = "\(indexPath.section)"
            label.tag = 1
            header.addSubview(label)
        }
        
        return header
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        let size = CGSizeMake(550, 250)
//        
//        return size
//    }
}
