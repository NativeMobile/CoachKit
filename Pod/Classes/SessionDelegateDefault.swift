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
    static let deviceName = UIDevice.current.name
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
        NotificationCenter.default.addObserver(self, selector: #selector(SessionDelegateDefault.willResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SessionDelegateDefault.didBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
#endif
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func willResignActive(_ notification: Notification) {
        NSLog("WillResignActive, disconnecting from peers %@", session?.connectedPeers ?? "[]")
        disconnect()
    }
    
    func didBecomeActive(_ notification: Notification) {
        NSLog("didBecomeActive")
    }
    
    func disconnect() {
        if session != nil {
            session!.disconnect()
        }
    }

    // All calls back to the delegate should go through this function to ensure consistent thread handling
    func callDelegate(_ call: @escaping () -> Void) {
        DispatchQueue.main.async(execute: { () -> Void in
            call()
        })
    }
    
    // MARK: PeerID storage
    class func getPeerId()-> MCPeerID {
        let defaults = UserDefaults.standard
        let peerIdData = defaults.data(forKey: PEER_STORAGE_KEY)
        if (peerIdData != nil) {
            // Was found in user defaults so deserialize
            let archivedPeer = NSKeyedUnarchiver.unarchiveObject(with: peerIdData!) as! MCPeerID
            NSLog("Found existing peerId %@", archivedPeer)
            return archivedPeer;
        } else {
            // Not found so create one and store in user defaults before returning
            let thisPeer = MCPeerID(displayName: deviceName)
            let peerData = NSKeyedArchiver.archivedData(withRootObject: thisPeer)
            defaults.set(peerData, forKey: PEER_STORAGE_KEY)
            defaults.synchronize()
            NSLog("Created new peerId %@", thisPeer)
            return thisPeer
        }
    }

    // MARK: Data exchange
    
    func sendMessageToPeersWithDictionary(_ dictionary: Dictionary<String, AnyObject>, peers: [MCPeerID], success: ()->(), failure: (_ error: String)-> ()) {
        // Note any peers in the 'toPeers' array argument are not connected this will fail.
        if session!.connectedPeers.count > 0 {
            let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
            var error: NSError?
            let sendSuccess: Bool
            do {
                try session!.send(data, toPeers: session!.connectedPeers, with: MCSessionSendDataMode.reliable)
                sendSuccess = true
            } catch let error1 as NSError {
                error = error1
                sendSuccess = false
            }
            
            if (sendSuccess) {
                success()
            } else {
                failure("Message could not be sent to all connected peers: \(error)")
            }
        } else {
            success()
        }
    }
    

    // MARK: MCSessionDelegate default implementation
    
    // Remote peer changed state
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("Peer %@ changed state to %@", peerID.displayName, stateDescription(state))
    }
    
    // Received data from remote peer
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, AnyObject>
        NSLog("Peer %@ has sent message %@", peerID, dictionary)
        
    }
    
    // Received a byte stream from remote peer
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("Received a byte stream from remote peer %@", peerID)
    }
    
    // Start receiving a resource from remote peer
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("didStartReceivingResourceWithName %@", resourceName)
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("didFinishReceivingResourceWithName %@", resourceName)
    }
    
    // Made first contact with peer and have identity information about the remote peer (certificate may be nil)
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: (@escaping (Bool) -> Void)) {
        certificateHandler(true);
    }
    
    func stateDescription(_ state: MCSessionState) -> String {
        switch state {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .notConnected:
            return "NotConnected"
        }
    }


}
