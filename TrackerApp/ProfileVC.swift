//
//  ProfileVC.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 9/21/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
   
    var mUserObj: UserObject! = nil

    @IBOutlet weak var online_icon: UIImageView!
    @IBOutlet weak var company_name_lbl: UILabel!
    @IBOutlet weak var email_lbl: UILabel!
    @IBOutlet weak var user_name_lbl: UILabel!
    @IBOutlet weak var profile_image: CircleImageView!
    @IBOutlet weak var profile_blur_background_img: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profile_blur_background_img.addBlurEffect()
        if mUserObj != nil{
            setViews()
        }
    }
    
    private func setViews(){
        user_name_lbl.text = mUserObj.userName!
        email_lbl.text = mUserObj.userEmail!
        company_name_lbl.text = mUserObj.companyName!
        
        profile_blur_background_img.imageFromServerURL(urlString: mUserObj.imageUrl!, defaultImage: "")
        profile_image.imageFromServerURL(urlString: mUserObj.imageUrl!, defaultImage: "")
        
        switch mUserObj.status! {
        case .OFFLINE:
            online_icon.isHidden = true
        case .ONLINE:
            online_icon.isHidden = false
        }

    }

    @IBAction func back_btn_pressed(_ sender: Any) {
        dismiss(animated: true, completion:  nil)
    }

}
