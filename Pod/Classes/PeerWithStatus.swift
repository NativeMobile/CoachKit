//
//  PeerWithStatus.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 27/06/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation
import MultipeerConnectivity;

open class PeerWithStatus {
    open let peer: MCPeerID
    open var state: String {
        didSet {
            lastStateChange = Date()
        }
    }
    open var lastStateChange: Date
    
    init (peerId: MCPeerID, sessionState: String) {
        peer = peerId
        state = sessionState
        lastStateChange = Date()
    }
    
}
