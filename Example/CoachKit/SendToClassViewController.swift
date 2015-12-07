//
//  SendToClassViewController.swift
//  CoachKitDemo
//
//  Created by Keith Coughtrey on 3/07/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation
import UIKit

class SendToClassViewController : UIViewController {
    
    @IBOutlet weak var messageTextField: UITextField!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        messageTextField!.becomeFirstResponder()
    }
}