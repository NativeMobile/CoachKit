//
//  PeerConnectionManager.swift
//  CoachKit
//
//  Created by Keith Coughtrey on 29/06/14.
//  Copyright (c) 2014 Keith Coughtrey. All rights reserved.
//

import Foundation
import CoreBluetooth;
import MultipeerConnectivity;

class PeerConnectionManager : SessionDelegateDefault, MCNearbyServiceBrowserDelegate {

    let queue = DispatchQueue(label: "nz.co.nativemobile.coachkit.queue", attributes: []) //Blocks submitted to a serial queue are executed one at a time in FIFO order
    var classPeers = [PeerWithStatus]()
    internal var serviceBrowser: MCNearbyServiceBrowser?
    internal weak var delegate: PeerConnectionManagerDelegate?
    internal var isBrowsing = false
    
    init(serviceName: String, peerConnectionManagerDelegate: PeerConnectionManagerDelegate) {
        delegate = peerConnectionManagerDelegate
        super.init(serviceName: serviceName)
    }
    
    func findPeersToJoinClass() {
        if (hasConnectedStudents()) {
            // Already have connected students - happens when our coach proxy disconnects and we reconnect to the coach
            // or coach proxy - i.e our immediate peer on the coach side dropped out of the chain and we connect to his coach
            NSLog("Will not start browsing as already have connected students")
        } else {
            session = MCSession(peer: thisPeer)
            session!.delegate = self;
            serviceBrowser = MCNearbyServiceBrowser(peer: thisPeer, serviceType: serviceName)
            serviceBrowser!.delegate = self
            startLookingForPeers()
        }
        
    }

    fileprivate func startLookingForPeers() {
        if !isBrowsing {
            if UIApplication.shared.applicationState == .active {
                serviceBrowser!.startBrowsingForPeers()
                isBrowsing = true
                NSLog("startBrowsingForPeers")
                callDelegate({ () -> Void in
                    self.delegate?.didStartBrowsingForPeers()
                })
            } else {
                NSLog("Ignoring request to start browsing as App is not active")
            }
        }
    }

    fileprivate func stopLookingForPeers() {
        if isBrowsing {
            serviceBrowser!.stopBrowsingForPeers()
            isBrowsing = false
            NSLog("stopBrowsingForPeers");
            callDelegate({ () -> Void in
                self.delegate?.didStopBrowsingForPeers()
            })
        }
    }
    
    func hasConnectedStudents() -> Bool {
        return !classPeers.isEmpty
    }
    
    override func disconnect() {
        stopLookingForPeers()
        callDelegate({ () -> Void in
            self.delegate?.didDisconnectFromSession()
        })
        super.disconnect()
    }
    
    func sendMessageToPeers(_ dictionary: Dictionary<String, AnyObject>, success: ()->(), failure: (_ error: String)-> ()) {
        NSLog("Sending data %@ to %@", dictionary, session!.connectedPeers);
        let peers = session!.connectedPeers as [MCPeerID]
        sendMessageToPeersWithDictionary(dictionary, peers: peers, success: success, failure: failure)
    }

    func sendMessageToPeerWithName(_ name: String, dictionary: Dictionary<String, AnyObject>, success: ()->(), failure: (_ error: String)-> ()) {
        let peers = session!.connectedPeers.filter { (peerID) -> Bool in
            return peerID.displayName == name
        }
        NSLog("Sending data %@ to %@", dictionary, peers);
        sendMessageToPeersWithDictionary(dictionary, peers: peers, success: success, failure: failure)
    }

    override func didBecomeActive(_ notification: Notification) {
        super.didBecomeActive(notification)
        if session != nil {
            NSLog("setting session delegate")
            session!.delegate = self;
            startLookingForPeers();
        }
    }
    
    // MARK: functions that should be queued to avoid concurrent access to classPeers
    
    fileprivate func foundNearbyPeer(_ peerID: MCPeerID) {
        NSLog("Processing found peer \(peerID)");
        if classPeers.count < maxPeers {
            // First see if the peer is already in the class
            let indexOfPeer = classPeers.index(where: { (peer) -> Bool in
                peer.peer.isEqual(peerID)
            })
            if let index = indexOfPeer {
                NSLog("Nearby peer \(peerID) is already a member of class peers and has state \(classPeers[index].state)")
                return
            }

            let peerWithStatus = PeerWithStatus(peerId: peerID, sessionState: "Invited")
            classPeers.append(peerWithStatus) //TODO: Remove peer if it doesn't progress to connecting within the timeout period below
            // Join them in to the session
            serviceBrowser!.invitePeer(peerID, to: session!, withContext: nil, timeout: 30)
            callDelegate({ () -> Void in
                self.delegate?.didIssueInvitationToJoinClass(peerID.displayName)
            })
            if classPeers.count >= maxPeers {
                stopLookingForPeers()
            }
            postClassChangedNotification()
        } else {
            NSLog("Ignoring nearby advertising peer as max peers already reached")
        }
    }
    
    fileprivate func peerChangedState(_ peerID: MCPeerID, state: MCSessionState) {
        let indexOfPeerThatChanged = classPeers.index(where: { (peer) -> Bool in
            peer.peer.isEqual(peerID)
        })
        guard let index = indexOfPeerThatChanged else {
            NSLog("Remote peer %@ was not found within class peers", peerID)
            return
        }
        classPeers[index].state = stateDescription(state)
        let name = classPeers[index].peer.displayName
        callDelegate({ () -> Void in
            switch state {
            case .connected:
                self.delegate?.studentDidConnect(name)
            case .connecting:
                self.delegate?.studentDidStartConnecting(name)
            case .notConnected:
                self.delegate?.studentDidDisconnect(name)
            }
        })
        if state == MCSessionState.notConnected {
            classPeers.remove(at: index)
            // We lost a student so ensure we are browsing for a replacement
            startLookingForPeers()
        }
        postClassChangedNotification()
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    
    // Found a nearby advertising peer
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("Found a nearby advertising peer \(peerID)")
        queue.sync(execute: {[weak self] () -> Void in
            self?.foundNearbyPeer(peerID)
        })
    }
    
    // A nearby peer has stopped advertising
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("A nearby peer %@ has stopped advertising", peerID)
    }
    
    // Browsing did not start due to an error
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("Browsing did not start due to an error \(error)")
    }
    
    // MARK: - MCSessionDelegate
    
    // Remote peer changed state
    override func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("Remote peer %@ changed state to %@", peerID, stateDescription(state))
        queue.sync(execute: {[weak self] () -> Void in
            self?.peerChangedState(peerID, state: state)
        })
    }
    
    // Received data from remote peer
    override func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, AnyObject>
        NSLog("Peer %@ has sent message %@", peerID, dictionary)
        callDelegate({ () -> Void in
            self.delegate?.didReceiveDictionaryFromPeerWithName(peerID.displayName, dictionary: dictionary)
        })
        
    }
    
    // MARK: Notifications
    
    func postClassChangedNotification() {
        DispatchQueue.main.async(execute: { () -> Void in
//            NSNotificationCenter.defaultCenter().postNotificationName(CoachKitConstants.classChangeNotificationName, object: self)
            //TODO: Update once I move to a framework
            NotificationCenter.default.post(name: Notification.Name(rawValue: "classMembersChanged"), object: self)
        })
    }
}
