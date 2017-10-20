//
//  GroupVC.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/18/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout

class GroupVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    var isfirstTimeTransform:Bool = true

    var groups = [GroupObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setupLayout()
        let nib = UINib(nibName: "GroupCollectionCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GroupCollectionCell")
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCollectionCell", for: indexPath) as? GroupCollectionCell{
      
            return cell;
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 220.0, height: 380.0)
    }
    fileprivate func setupLayout() {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 180)
    }
}
