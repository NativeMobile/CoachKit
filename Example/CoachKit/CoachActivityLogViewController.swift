//
//  CoachActivityLogViewController.swift
//  CoachKitDemo
//
//  Created by Keith Coughtrey on 30/06/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation
import UIKit
import CoachKit

class CoachActivityLogViewController :  ActivityLogViewController, PeerConnectionManagerDelegate {
    var manager: CoachingManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CoachingManager(serviceName: "coachkit-demo", peerConnectionManagerDelegate: self)
        manager!.startCoachingSession()
    }
    
    // MARK: Unwind segues
    
    @IBAction func sendMessage(segue:UIStoryboardSegue) {
        let vc = segue.sourceViewController as! SendToClassViewController
        let message = ["text":vc.messageTextField.text!];
        
        manager?.sendMessageToPeers(message, success: { () -> () in
            self.addLogItem("Message was sent to class")
            }, failure: { (error: String) -> () in
            self.addLogItem(error)
        })
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
    }
    // MARK: Segue handling
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowClass" {
            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.topViewController as! PeerConnectionViewController
            vc.manager = manager
            
        }
    }
}