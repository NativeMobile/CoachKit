//
//  PeerConnectionViewController.swift
//  CoachKitDemo
//
//  Created by Keith Coughtrey on 27/06/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation
import UIKit
import CoachKit

public class PeerConnectionViewController : UIViewController, UICollectionViewDataSource {
    
    public var manager: CoachingManager? //TODO: Make this private?
    
    @IBOutlet weak var peerCollectionView: UICollectionView!

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(classChanged), name: NSNotification.Name(CoachKitConstants.classChangeNotificationName), object: nil)

    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func classChanged(notification: Notification) {
        peerCollectionView.reloadData()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let manager = manager {
            return manager.classPeers.count
        } else {
            return 0
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeerCell", for: indexPath) as! PeerCell
        let peerWithStatus = manager!.classPeers[indexPath.row]
        cell.peerName.text = peerWithStatus.peer.displayName;
        cell.peerStatus.text = peerWithStatus.state;
        return cell;

    }
}
