//
//  UserCollectionCell.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/11/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class UserCollectionCell: UICollectionViewCell,Shakeable,Floatable {

    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var profile_image: CircleImageView!
    @IBOutlet weak var user_status_image: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(userObj: UserObject){
        user_name.text = userObj.userName?.components(separatedBy: " ").first
        if let imageUrl = userObj.imageUrl{
            profile_image.imageFromServerURL(urlString: imageUrl, defaultImage: "")
        }
        switch userObj.status! {
        case .ONLINE:
            user_status_image.isHidden = false
            user_status_image.image = UIImage(named: "icon_online.png")
        case .OFFLINE:
            user_status_image.image = UIImage(named: "icon_offline.png")
        }
    }

}
