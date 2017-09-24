//
//  ChatObject.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 9/24/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation

class ChatObject {
    private var _senderId: String!
    private var _senderName: String!
    private var _message: String!
    private var _time: String!
    private var _date: String!
    private var _image_url: String!
    
    var senderId: String!{
        return _senderId
    }
    var senderName: String!{
        return _senderName
    }
    var image_url: String!{
        return _image_url
    }
    var message: String!{
        return _message
    }
    var time: String!{
        return _time
    }
    var date: String!{
        return _date
    }
    
    init(senderId: String,senderName: String,message: String,time: String,date: String,image_url: String) {
        self._senderId = senderId
        self._senderName = senderName
        self._message = message
        self._time = time
        self._date = date
        self._image_url = image_url

    }
    
    init(senderId: String) {
        self._senderId = senderId
    }
    

}
