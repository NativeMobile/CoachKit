//
//  PeerConnectionListener.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 25/05/14.
//  Copyright (c) 2014 Keith Coughtrey. All rights reserved.
//

import Foundation
import MultipeerConnectivity;

class PeerConnectionListener: SessionDelegateDefault, MCNearbyServiceAdvertiserDelegate {
    
    internal var coachPeer: MCPeerID?
    internal var serviceBrowser: MCNearbyServiceBrowser?
    internal var advertiser: MCNearbyServiceAdvertiser?
    internal weak var delegate: PeerConnectionListenerDelegate?
    internal var isAdvertising = false
    
    init(serviceName: String, peerConnectionListenerDelegate: PeerConnectionListenerDelegate) {
        delegate = peerConnectionListenerDelegate
        super.init(serviceName: serviceName)
    }
    

    func startAdvertisingWillingnessToJoinTeachingSession() {
        session = MCSession(peer: thisPeer)
        session!.delegate = self;
        
        // Here we set a nearby service advertiser that tells nearby peers that this app is willing to join sessions of a specified type.
        advertiser = MCNearbyServiceAdvertiser(peer: thisPeer, discoveryInfo: nil, serviceType: serviceName)
        advertiser!.delegate = self;
        startAdvertisingForPeers()
    
    }
    
    fileprivate func startAdvertisingForPeers() {
        if !isAdvertising {
            if UIApplication.shared.applicationState == .active {
                advertiser!.startAdvertisingPeer()
                isAdvertising = true
                NSLog("Started advertising")
                callDelegate({ () -> Void in
                    self.delegate?.didStartAdvertisingForPeers();
                })
            } else {
                NSLog("Ignoring request to start advertising as App is not active")
            }
        } else {
            NSLog("Already advertising")
        }
    }
    
    fileprivate func stopAdvertisingForPeers() {
        if isAdvertising {
            advertiser!.stopAdvertisingPeer()
            isAdvertising = false
            NSLog("Stopped advertising")
            callDelegate({ () -> Void in
                self.delegate?.didStopAdvertisingForPeers()
            })
        }
    }
    
    override func disconnect() {
        stopAdvertisingForPeers()
        callDelegate { () -> Void in
            self.delegate?.didDisconnectFromClass()
        }
        super.disconnect()
    }
    
    func sendMessageToCoach(_ dictionary: Dictionary<String, AnyObject>, success: ()->(), failure: (_ error: String)-> ()) {
        let peers = [coachPeer!]
        sendMessageToPeersWithDictionary(dictionary, peers: peers, success: success, failure: failure)
    }
    
    override func didBecomeActive(_ notification: Notification) {
        super.didBecomeActive(notification)
        if session != nil {
            NSLog("setting session delegate")
            session!.delegate = self;
            startAdvertisingForPeers();
        }
    }
    
    // MARK: MCNearbyServiceAdvertiserDelegate
    
    // Incoming invitation request.  Call the invitationHandler block with YES and a valid session to connect the inviting peer to the session.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("Incoming invitation from peer %@", peerID.displayName);
        // Accept the invitation
        coachPeer = peerID;
        invitationHandler(true, session!);
        callDelegate({ () -> Void in
            self.delegate?.didAcceptInvitationToJoinClass()
        })
    }
    
    // Advertising did not start due to an error
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("Advertising did not start due to an error \(error)")
    }

    // MARK: - MCSessionDelegate
    
    // Remote peer changed state
    override func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("Peer %@ changed state to %@", peerID, stateDescription(state))
        if peerID.isEqual(coachPeer) {
            switch state {
            case .connecting:
                stopAdvertisingForPeers()
                callDelegate({ () -> Void in
                    self.delegate?.didStartConnectingToCoachingSession()
                })
            case .connected:
                callDelegate({ () -> Void in
                    self.delegate?.didConnectToCoachingSession()
                })
            case .notConnected:
                NSLog("Coach disconnected for coaching session");
                callDelegate({ () -> Void in
                    self.delegate?.didDisconnectFromCoachingSession()
                })
                // I have found that the class member gets notified that the teacher disconnected but the teacher gets no message
                // about the class member. By calling disconnect I hope to ensure the teacher gets notified.
                disconnect()
                startAdvertisingForPeers()
            }
        } else {
            NSLog("State change was for another class member so ignored")
        }
        
    }
    
    // Received data from remote peer
    override func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, AnyObject>
        NSLog("Peer %@ has sent message %@", peerID, dictionary)
        callDelegate({ () -> Void in
            self.delegate?.didReceiveDictionary(dictionary)
        })
        
    }

}
