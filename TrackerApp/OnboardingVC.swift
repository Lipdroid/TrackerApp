//
//  OnboardingVC.swift
//  TrackerApp
//
//  Created by Lipu Hossain on 10/14/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit
import paper_onboarding

class OnboardingVC: UIViewController,PaperOnboardingDataSource,PaperOnboardingDelegate {

    @IBOutlet weak var paperView: PaperOnboarding!
    @IBOutlet weak var btn_getStarted: RoundedCornerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paperView.delegate = self
        paperView.dataSource = self
    }
    
    @IBAction func onclick_getStarted(_ sender: Any) {
        performSegue(withIdentifier: Constants.ONBOARDING_LOGIN_SEGUE_IDENTIFIER, sender: nil)
    }
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        let backgroungColorOne = UIColor(red: 255/255, green: 220/255, blue: 90/255, alpha: 1)
        let backgroungColorTwo = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
        let backgroungColorThree = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        
        let titleFont = UIFont(name: "AvenirNext-Bold", size: 24)!
        let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 18)!

        return [
            ("icon_tracking", "Tracker", "Track your family,group,employee", "", backgroungColorOne, UIColor.white, UIColor.white, titleFont, descriptionFont),
            ("icon_chatroom", "Title", "Description text", "", backgroungColorTwo, UIColor.white, UIColor.white, titleFont, descriptionFont),
            ("icon_chatroom", "Title", "Description text", "", backgroungColorThree, UIColor.white, UIColor.white, titleFont, descriptionFont)
            ][index]
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        //
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 2{
            self.btn_getStarted.alpha = 1
            //for bounce popup animation
            let identityAnimation = CGAffineTransform.identity
            let scaleOfIdentity = identityAnimation.scaledBy(x: 0.001, y: 0.001)
            self.btn_getStarted.transform = scaleOfIdentity
            UIView.animate(withDuration: 0.3/1.5, animations: {
                let scaleOfIdentity = identityAnimation.scaledBy(x: 1.1, y: 1.1)
                self.btn_getStarted.transform = scaleOfIdentity
            }, completion: {finished in
                UIView.animate(withDuration: 0.3/2, animations: {
                    let scaleOfIdentity = identityAnimation.scaledBy(x: 0.9, y: 0.9)
                    self.btn_getStarted.transform = scaleOfIdentity
                }, completion: {finished in
                    UIView.animate(withDuration: 0.3/2, animations: {
                        self.btn_getStarted.transform = identityAnimation
                    })
                })
            })
           
        }
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 1{
            if btn_getStarted.alpha == 1{
                UIView.animate(withDuration: 0.4, animations: {
                    self.btn_getStarted.alpha = 0
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
