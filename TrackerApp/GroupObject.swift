//
//  GroupObject.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/18/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation

class GroupObject{
    private var _group_name: String!
    private var _group_member_count:String!
    
    var group_name: String {
        return _group_name
    }
    var group_member_count: String{
        return _group_member_count
    }
    init(group_name: String,group_member_count: String) {
        self._group_name = group_name
        self._group_member_count = group_member_count
    }
}
