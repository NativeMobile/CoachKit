//
//  ActivityLogViewController.swift
//  CoachKitDemo
//
//  Created by Keith Coughtrey on 26/06/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import UIKit
import CoachKit

class ActivityLogViewController: UITableViewController, ActivityLogger {

    let formatter = DateFormatter()
    var activityItems = [ActivityLogItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        formatter.dateFormat = "HH':'mm':'ss'.'SSS"
    }
    
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityLogItem") as! ActivityLogTableViewCell
        let item = activityItems[indexPath.row]
        cell.message.text = "\(item.time)- \(item.message)"
        return cell
    }

    // MARK: Helpers
    func addLogItem(_ message: String) {
        NSLog("Adding log message: \(message)")
        let time = formatter.string(from: Date())
        let item = ActivityLogItem(time: time, message: message)
        activityItems.append(item)
        tableView.reloadData()
        
    }
}

