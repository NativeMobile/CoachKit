//
//  PeerConnectionManagerDelegate.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 27/06/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation

public protocol PeerConnectionManagerDelegate : class {
    func didStartBrowsingForPeers()
    func didStopBrowsingForPeers()
    func didDisconnectFromSession()
    func didIssueInvitationToJoinClass(inviteeName: String)
    func studentDidStartConnecting(name: String)
    func studentDidConnect(name: String)
    func studentDidDisconnect(name: String)
    func didReceiveDictionaryFromPeerWithName(name: String, dictionary: Dictionary<String, AnyObject>)
}