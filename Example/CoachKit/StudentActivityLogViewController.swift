//
//  StudentActivityLogViewController.swift
//  CoachKitDemo
//
//  Created by Keith Coughtrey on 30/06/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation
import UIKit
import CoachKit

class StudentActivityLogViewController :  ActivityLogViewController, PeerConnectionListenerDelegate {
    var manager: CoachConnectionManager?
    
    @IBOutlet weak var classButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CoachConnectionManager(serviceName: "coachkit-demo", peerConnectionListenerDelegate: self)
        manager!.connectToCoach()
    }

// MARK: PeerConnectionListenerDelegate
    
    func didDisconnectFromSession() {
        addLogItem("This device disconnected")        
        classButton!.tintColor = UIColor.redColor()
    }
    
    func didStartConnectingToCoachingSession() {
        addLogItem("Started connecting to a class")
        classButton!.tintColor = UIColor.orangeColor()
    }

    func didConnectToCoachingSession() {
        addLogItem("Did connect to a class")
        classButton!.tintColor = UIColor.greenColor()
    }

    func didDisconnectFromCoachingSession() {
        addLogItem("The coach disconnected")        
        classButton!.tintColor = UIColor.redColor()
    }

}