//
//  HistoryVC.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 9/20/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit
import Firebase

class HistoryVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    struct Objects {
        var sectionName: String!
        var sectionObjects: [String]!
    }
    var objectsArray = [Objects]()
    var historyDict = [String: [String]]()
    @IBOutlet weak var tableView: UITableView!
    var mUserObj: UserObject?
    let TAG = "HistoryVC"
    var tripIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        getAllHistoryData()
    }

    @IBAction func back_btn_pressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return objectsArray.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return objectsArray[section].sectionName
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsArray[section].sectionObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as? HistoryCell{
            let id = objectsArray[indexPath.section].sectionObjects[indexPath.row]
            cell.configureCell(id: id)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        returnedView.backgroundColor = .black
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width, height: 25))
        label.text = objectsArray[section].sectionName
        label.textColor = .white
        returnedView.addSubview(label)
        
        return returnedView
    }
   
    // MARK: - Fetching Data from firebase
    func getAllHistoryData(){
        DADataService.instance.REF_COMPANY.child(Constants.DEFAULT_COMPANY_NAME).child("history").child((mUserObj?.userNodeId!)!).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get all history
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        //remove if their is any previous information about history
                        self.historyDict.removeAll()
                        self.objectsArray.removeAll()
                        for historySnap in snapshots {
                            //date as key
                            print("\(self.TAG): History Dates:\(historySnap.key)")

                            //get all the trip ids
                            if let tripIds = historySnap.value as? Dictionary<String, AnyObject>{
                                self.tripIDs.removeAll()
                                for tripID in tripIds{
                                    print("\(tripID.key)")
                                    //got the trip ids
                                    self.tripIDs.append(tripID.key)
                                }
                            }
                            self.objectsArray.append(Objects(sectionName: historySnap.key, sectionObjects: self.tripIDs))
                            self.historyDict.updateValue(self.tripIDs, forKey: historySnap.key)
                        }
                        self.tableView.reloadData()
                    }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
