//
//  SessionDelegateDefault.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 27/06/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation
import MultipeerConnectivity;

class SessionDelegateDefault : NSObject, MCSessionDelegate {
    
    static let PEER_STORAGE_KEY = "peer_id_key"
#if os(iOS)
    static let deviceName = UIDevice.currentDevice().name
#else
    static let deviceName = NSHost.currentHost().localizedName!
#endif
    
    let serviceName: String // Must be lowercase and 1-15 characters
    let maxPeers = 7

    internal let thisPeer: MCPeerID
    internal var session: MCSession?
    
    init(serviceName: String) {
        self.serviceName = serviceName
        thisPeer = SessionDelegateDefault.getPeerId()
        super.init()
#if os(iOS)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willResignActive:", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
#endif
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func willResignActive(notification: NSNotification) {
        NSLog("WillResignActive, disconnecting from peers %@", session?.connectedPeers ?? "[]")
        disconnect()
    }
    
    func didBecomeActive(notification: NSNotification) {
        NSLog("didBecomeActive")
    }
    
    func disconnect() {
        if session != nil {
            session!.disconnect()
        }
    }

    // All calls back to the delegate should go through this function to ensure consistent thread handling
    func callDelegate(call: () -> Void) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            call()
        })
    }
    
    // MARK: PeerID storage
    class func getPeerId()-> MCPeerID {
        let defaults = NSUserDefaults.standardUserDefaults()
        let peerIdData = defaults.dataForKey(PEER_STORAGE_KEY)
        if (peerIdData != nil) {
            // Was found in user defaults so deserialize
            let archivedPeer = NSKeyedUnarchiver.unarchiveObjectWithData(peerIdData!) as! MCPeerID
            NSLog("Found existing peerId %@", archivedPeer)
            return archivedPeer;
        } else {
            // Not found so create one and store in user defaults before returning
            let thisPeer = MCPeerID(displayName: deviceName)
            let peerData = NSKeyedArchiver.archivedDataWithRootObject(thisPeer)
            defaults.setObject(peerData, forKey: PEER_STORAGE_KEY)
            defaults.synchronize()
            NSLog("Created new peerId %@", thisPeer)
            return thisPeer
        }
    }

    // MARK: Data exchange
    
    func sendMessageToPeersWithDictionary(dictionary: Dictionary<String, AnyObject>, peers: [MCPeerID], success: ()->(), failure: (error: String)-> ()) {
        // Note any peers in the 'toPeers' array argument are not connected this will fail.
        if session!.connectedPeers.count > 0 {
            let data = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
            var error: NSError?
            let sendSuccess: Bool
            do {
                try session!.sendData(data, toPeers: session!.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                sendSuccess = true
            } catch let error1 as NSError {
                error = error1
                sendSuccess = false
            }
            
            if (sendSuccess) {
                success()
            } else {
                failure(error: "Message could not be sent to all connected peers: \(error)")
            }
        } else {
            success()
        }
    }
    

    // MARK: MCSessionDelegate default implementation
    
    // Remote peer changed state
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("Peer %@ changed state to %@", peerID.displayName, stateDescription(state))
    }
    
    // Received data from remote peer
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let dictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Dictionary<String, AnyObject>
        NSLog("Peer %@ has sent message %@", peerID, dictionary)
        
    }
    
    // Received a byte stream from remote peer
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("Received a byte stream from remote peer %@", peerID)
    }
    
    // Start receiving a resource from remote peer
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("didStartReceivingResourceWithName %@", resourceName)
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("didFinishReceivingResourceWithName %@", resourceName)
    }
    
    // Made first contact with peer and have identity information about the remote peer (certificate may be nil)
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: ((Bool) -> Void)) {
        certificateHandler(true);
    }
    
    func stateDescription(state: MCSessionState) -> String {
        switch state {
        case .Connected:
            return "Connected"
        case .Connecting:
            return "Connecting"
        case .NotConnected:
            return "NotConnected"
        }
    }


}