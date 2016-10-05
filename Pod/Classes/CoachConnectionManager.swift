//
//  CoachConnectionManager.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 19/07/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation

open class CoachConnectionManager {
    
    fileprivate let listener: PeerConnectionListener
    
    public init(serviceName: String, peerConnectionListenerDelegate: PeerConnectionListenerDelegate) {
        listener = PeerConnectionListener(serviceName: serviceName, peerConnectionListenerDelegate: peerConnectionListenerDelegate)
    }
    
    open func connectToCoach() {
        listener.startAdvertisingWillingnessToJoinTeachingSession()
    }
    
    open func sendMessageToCoach(_ dictionary: Dictionary<String, AnyObject>, success: ()->(), failure: (_ error: String)-> ()) {
        listener.sendMessageToCoach(dictionary, success: success, failure: failure)
    }
}
