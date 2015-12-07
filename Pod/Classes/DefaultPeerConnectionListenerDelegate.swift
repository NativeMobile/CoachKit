//
//  DefaultPeerConnectionListenerDelegate.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 11/07/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation

public extension PeerConnectionListenerDelegate where Self : ActivityLogger {
    func didStartAdvertisingForPeers() {
        addLogItem("Started advertising willingness to join class")
    }
    
    func didStopAdvertisingForPeers() {
        addLogItem("Stopped advertising willingness to join class")
    }
    
    func didDisconnectFromSession() {
        addLogItem("This device disconnected")
    }
    
    func didAcceptInvitationToJoinClass() {
        addLogItem("Accepted an invitation to join a class")
    }
    
    func didStartConnectingToCoachingSession() {
        addLogItem("Started connecting to a class")
    }
    
    func didConnectToCoachingSession() {
        addLogItem("Did connect to a class")
    }
    
    func didDisconnectFromCoachingSession() {
        addLogItem("The coach disconnected")
    }
    
    func didReceiveDictionary(dictionary: Dictionary<String, AnyObject>) {
        addLogItem("Received data from coach: \(dictionary) ")
    }

}