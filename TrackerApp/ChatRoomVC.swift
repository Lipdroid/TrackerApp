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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.message_text.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        getAllChatData()
        

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as? ChatCell{
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }else{
            return UITableViewCell()
        }    }
    
    
    
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

    func getAllChatData(){
        Progress.sharedInstance.showLoading()
        DADataService.instance.REF_COMPANY.child(Constants.DEFAULT_COMPANY_NAME).child("ChatGroup").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get all user
            print("finish getting all user data")
            Progress.sharedInstance.dismissLoading()
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                print("chat count:\(snapshots.count)")
                //remove if their is any previous information about emplyoee/user
                self.chats.removeAll()
                for snap in snapshots {
                    if let chat_snap = snap.value as? Dictionary<String, String>{
                        if let chat = self.parseChatSnap(uid: snap.key, chatSnapDict: chat_snap){
                            self.chats.append(chat)
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
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
    
    func parseChatSnap(uid: String,chatSnapDict: Dictionary<String,String>)->ChatObject?{
        var chatObj = ChatObject(senderId: uid)
        
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
        
        
        
        chatObj = ChatObject(senderId: senderId, senderName: senderName, message: message, time: time, date: date, image_url: iamgeUrl)
        
        return chatObj
    }

}
