//
//  UserChatCell.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 9/25/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class UserChatCell: UITableViewCell {

    @IBOutlet weak var message_lbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(chat: ChatObject){
        
        message_lbl.text = chat.message
        message_lbl.layer.cornerRadius = 5.0
        message_lbl.clipsToBounds = true
        
    }

}
