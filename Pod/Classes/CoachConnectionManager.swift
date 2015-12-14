//
//  CoachConnectionManager.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 19/07/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation

public class CoachConnectionManager {
    
    private let listener: PeerConnectionListener
    
    public init(serviceName: String, peerConnectionListenerDelegate: PeerConnectionListenerDelegate) {
        listener = PeerConnectionListener(serviceName: serviceName, peerConnectionListenerDelegate: peerConnectionListenerDelegate)
    }
    
    public func connectToCoach() {
        listener.startAdvertisingWillingnessToJoinTeachingSession()
    }
    
    public func sendMessageToCoach(dictionary: Dictionary<String, AnyObject>, success: ()->(), failure: (error: String)-> ()) {
        listener.sendMessageToCoach(dictionary, success: success, failure: failure)
    }
}