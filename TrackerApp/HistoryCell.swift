//
//  HistoryCell.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/8/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var tripId_lbl: UILabel!
    
    func configureCell(id: String){
        self.tripId_lbl.text = id
    }

}
