//
//  ChatCell.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 9/24/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var name_lbl: UILabel!
    @IBOutlet weak var message_lbl: UILabel!
    @IBOutlet weak var time_lbl: UILabel!
    @IBOutlet weak var profile_image: CircleImageView!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sizeToFit()
        layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(chat: ChatObject){
    
        name_lbl.text = chat.senderName
        message_lbl.text = chat.message
        time_lbl.text = chat.time
        profile_image.imageFromServerURL(urlString: chat.image_url, defaultImage: "No Image")
        profile_image.clipsToBounds = true
    
    }
    
    

}
