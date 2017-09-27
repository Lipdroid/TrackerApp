//
//  ChatRoomVC.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 9/20/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomVC: UIViewController, UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var message_text: UITextField!
    var chats = [ChatObject]()
    var mUserObj: UserObject! = nil
    private let TAG = "ChatRoomVC"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshChatList), name: NSNotification.Name(rawValue: "refreshChatList"), object: nil)


        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.message_text.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 600.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()

        self.tableView.reloadData()
        self.tableViewScrollToBottom(animated: true)
        DADataService.instance.update_notification_count_for_user(uid: mUserObj.userNodeId!, companyName: mUserObj.companyName!, count: "\(chats.count)") {(response) in
        
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableViewScrollToBottom(animated: true)

    }
    func refreshChatList(notification: NSNotification){
        //load data here
        print("\(TAG): tableview refreshed")
        let chat = notification.userInfo!["snap"] as! ChatObject
        if let index = self.chats.index(where: { $0.chatId == chat.chatId }) {
            self.chats.remove(at: index)
            //continue do: arrPickerData.append(...)
        }
        //add that item
        self.chats.append(chat)
        print("\(self.TAG): received new message")
        self.tableView.reloadData()
        self.tableViewScrollToBottom(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = chats[indexPath.row] as? ChatObject{
            if(item.senderId == mUserObj.userNodeId){
                if let cell = tableView.dequeueReusableCell(withIdentifier: "userChatCell", for: indexPath) as? UserChatCell{
                    if let item = chats[indexPath.row] as? ChatObject{
                        cell.configureCell(chat: item)
                        return cell
                    }
                    return UserChatCell()
                }
            }else{
                if let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatCell{
                    if let item = chats[indexPath.row] as? ChatObject{
                        cell.configureCell(chat: item)
                        return cell
                    }
                    return ChatCell()
                }
            }
        }
        return UITableViewCell()
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func configureCell(cell: ChatCell,indexPath: IndexPath){
        if let item = chats[indexPath.row] as? ChatObject{
            cell.configureCell(chat: item)
        }
    }
    
    // UITableViewAutomaticDimension calculates height of label contents/text
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func back_btn_pressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func parseChatSnap(chatId: String,chatSnapDict: Dictionary<String,String>)->ChatObject?{
        var chatObj = ChatObject()
        
        guard let senderName = chatSnapDict["senderName"] else{
            return chatObj
        }
        guard let senderId = chatSnapDict["senderId"] else{
            return chatObj
        }
        guard let date = chatSnapDict["date"] else{
            return chatObj
        }
        guard let iamgeUrl = chatSnapDict["imageUrl"] else{
            return chatObj
        }
        guard let message = chatSnapDict["message"] else{
            return chatObj
        }
        guard let time = chatSnapDict["time"] else{
            return chatObj
        }
        
        
        
        chatObj = ChatObject(chatId: chatId,senderId: senderId, senderName: senderName, message: message, time: time, date: date, image_url: iamgeUrl)
        
        return chatObj
    }

    @IBAction func send_btn_pressed(_ sender: Any) {
        guard let text = message_text.text, !(message_text.text?.isEmpty)! else {
            return
        }
        DADataService.instance.createFirebaseDBChat(message: text, userObject: mUserObj)
        self.view.endEditing(true)
        message_text.text = ""

    }
    
    
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
}


