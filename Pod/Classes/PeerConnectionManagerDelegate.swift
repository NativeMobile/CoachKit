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
    func didIssueInvitationToJoinClass(_ inviteeName: String)
    func studentDidStartConnecting(_ name: String)
    func studentDidConnect(_ name: String)
    func studentDidDisconnect(_ name: String)
    func didReceiveDictionaryFromPeerWithName(_ name: String, dictionary: Dictionary<String, AnyObject>)
}
