        //
//  UserCell.swift
//  TrackerApp
//
//  Created by Lipu Hossain on 9/19/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var profile_image: CircleImageView!
    @IBOutlet weak var user_status_image: UIImageView!
    @IBOutlet weak var user_name: UILabel!
    @IBOutlet weak var user_status_label: UILabel!
    @IBOutlet weak var user_route_status_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(userObj: UserObject){
        user_name.text = userObj.userName
        user_route_status_label.text = "Trip: \(userObj.userRouteStatus ?? "Not Started")"
        if let imageUrl = userObj.imageUrl{
            profile_image.imageFromServerURL(urlString: imageUrl, defaultImage: "")
        }
        switch userObj.status! {
        case .ONLINE:
            user_status_image.isHidden = false
            user_status_image.image = UIImage(named: "icon_online.png")
            user_status_label.text = "online"
        case .OFFLINE:
            user_status_image.isHidden = true
            user_status_label.text = "offline"
        }
    }

}
