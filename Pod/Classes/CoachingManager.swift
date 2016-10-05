//
//  CoachingManager.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 19/07/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation

open class CoachingManager {
    fileprivate let manager: PeerConnectionManager
    open var classPeers: [PeerWithStatus] {
        get {
            let peers = manager.classPeers
            return peers
        }
    }
    
    public init(serviceName: String, peerConnectionManagerDelegate: PeerConnectionManagerDelegate) {
        manager = PeerConnectionManager(serviceName: serviceName, peerConnectionManagerDelegate: peerConnectionManagerDelegate)
    }
    
    open func startCoachingSession() {
        manager.findPeersToJoinClass()
    }
    
    open func sendMessageToPeers(_ dictionary: Dictionary<String, AnyObject>, success: ()->(), failure: (_ error: String)-> ()) {
        manager.sendMessageToPeers(dictionary, success: success, failure: failure)
    }

    open func sendMessageToPeerWithName(_ name: String, dictionary: Dictionary<String, AnyObject>, success: ()->(), failure: (_ error: String)-> ()) {
        manager.sendMessageToPeerWithName(name, dictionary: dictionary, success: success, failure: failure)
    }
    

}
