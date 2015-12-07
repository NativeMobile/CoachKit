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

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "classChanged:", name: CoachKitConstants.classChangeNotificationName, object: nil)

    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func classChanged(notification: NSNotification) {
        peerCollectionView.reloadData()
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let manager = manager {
            return manager.classPeers.count
        } else {
            return 0
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PeerCell", forIndexPath: indexPath) as! PeerCell
        let peerWithStatus = manager!.classPeers[indexPath.row]
        cell.peerName.text = peerWithStatus.peer.displayName;
        cell.peerStatus.text = peerWithStatus.state;
        return cell;

    }
}