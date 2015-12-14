//
//  CoachingManager.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 19/07/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation

public class CoachingManager {
    private let manager: PeerConnectionManager
    public var classPeers: [PeerWithStatus] {
        get {
            let peers = manager.classPeers
            return peers
        }
    }
    
    public init(serviceName: String, peerConnectionManagerDelegate: PeerConnectionManagerDelegate) {
        manager = PeerConnectionManager(serviceName: serviceName, peerConnectionManagerDelegate: peerConnectionManagerDelegate)
    }
    
    public func startCoachingSession() {
        manager.findPeersToJoinClass()
    }
    
    public func sendMessageToPeers(dictionary: Dictionary<String, AnyObject>, success: ()->(), failure: (error: String)-> ()) {
        manager.sendMessageToPeers(dictionary, success: success, failure: failure)
    }

    public func sendMessageToPeerWithName(name: String, dictionary: Dictionary<String, AnyObject>, success: ()->(), failure: (error: String)-> ()) {
        manager.sendMessageToPeerWithName(name, dictionary: dictionary, success: success, failure: failure)
    }
    

}