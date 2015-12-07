//
//  PeerConnectionListenerDelegate.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 29/06/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation

public protocol PeerConnectionListenerDelegate : class {

    func didStartAdvertisingForPeers()
    func didStopAdvertisingForPeers()
    func didDisconnectFromSession()
    func didAcceptInvitationToJoinClass()
    func didStartConnectingToCoachingSession()
    func didConnectToCoachingSession()
    func didDisconnectFromCoachingSession()
    func didReceiveDictionary(dictionary: Dictionary<String, AnyObject>)

}