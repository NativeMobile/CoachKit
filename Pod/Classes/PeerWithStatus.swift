//
//  PeerWithStatus.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 27/06/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation
import MultipeerConnectivity;

public class PeerWithStatus {
    public let peer: MCPeerID
    public var state: String {
        didSet {
            lastStateChange = NSDate()
        }
    }
    public var lastStateChange: NSDate
    
    init (peerId: MCPeerID, sessionState: String) {
        peer = peerId
        state = sessionState
        lastStateChange = NSDate()
    }
    
}