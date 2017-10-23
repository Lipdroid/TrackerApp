//
//  GroupVC.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/18/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout

class GroupVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var isfirstTimeTransform:Bool = true

    var groups = [GroupObject]()
    
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var btn_create_new_group: RoundedCornerButton!
    private var search_bar_shown = false
    @IBOutlet weak var finger_view: FloatingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        search_bar.delegate = self
        setupLayout()
        search_bar.returnKeyType = UIReturnKeyType.done
        let nib = UINib(nibName: "GroupCollectionCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GroupCollectionCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let indexPath = IndexPath(row: 1, section: 0)
//        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCollectionCell", for: indexPath) as? GroupCollectionCell{
            if(indexPath.row == 0){
            
            }
            return cell;
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 250.0, height: 380.0)
    }
    fileprivate func setupLayout() {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 180)
    }
    
    
    @IBAction func search_icon_pressed(_ sender: Any) {
            toggle_search_bar()
    }
    @IBAction func btn_new_group_pressed(_ sender: Any) {
    }
    
    
    
    private func show_search_bar(){
        self.search_bar.alpha = 1
        btn_search.isHidden = true
        //for bounce popup animation
        let identityAnimation = CGAffineTransform.identity
        let scaleOfIdentity = identityAnimation.scaledBy(x: 0.001, y: 0.001)
        self.search_bar.transform = scaleOfIdentity
        UIView.animate(withDuration: 0.3/1.5, animations: {
            let scaleOfIdentity = identityAnimation.scaledBy(x: 1.1, y: 1.1)
            self.search_bar.transform = scaleOfIdentity
        }, completion: {finished in
            UIView.animate(withDuration: 0.3/2, animations: {
                let scaleOfIdentity = identityAnimation.scaledBy(x: 0.9, y: 0.9)
                self.search_bar.transform = scaleOfIdentity
            }, completion: {finished in
                UIView.animate(withDuration: 0.3/2, animations: {
                    self.search_bar.transform = identityAnimation
                })
            })
        })
        
    }
    
    private func hide_search_bar(){
        //for bounce popup animation
        btn_search.isHidden = false
        let identityAnimation = CGAffineTransform.identity
        let scaleOfIdentity = identityAnimation.scaledBy(x: 1.0, y: 1.0)
        self.search_bar.transform = scaleOfIdentity
        UIView.animate(withDuration: 0.3/1.5, animations: {
            let scaleOfIdentity = identityAnimation.scaledBy(x: 0.001, y: 0.001)
            self.search_bar.transform = scaleOfIdentity
        }, completion: {finished in
            UIView.animate(withDuration: 0.3/2, animations: {
                let scaleOfIdentity = identityAnimation.scaledBy(x: 0.0, y: 0.0)
                self.search_bar.transform = scaleOfIdentity
            }, completion: {finished in
                UIView.animate(withDuration: 0.3/2, animations: {
                    self.search_bar.alpha = 0
                })
            })
        })
        
    }
    
    private func toggle_search_bar(){
        if(!search_bar_shown){
            show_search_bar()
        }else{
            hide_search_bar()
        }
        search_bar_shown = !search_bar_shown
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text == nil || searchBar.text == ""{
//            isSearching = false
//            view.endEditing(true)
//            collectionView.reloadData()
//        }else{
//            isSearching = true
//            filter_employee = employees.filter{$0.userName!.starts(with: searchBar.text!) }
//            collectionView.reloadData()
//        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        //isSearching = false;
        self.search_bar.endEditing(true)
        toggle_search_bar()
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Your code here
        finger_view.isHidden = true
    }
}
