//
//  ActivityLogItem.swift
//  CoachKitDemo
//
//  Created by Keith Coughtrey on 6/07/15.
//  Copyright © 2015 Keith Coughtrey. All rights reserved.
//

import Foundation

class ActivityLogItem {
    let time: String
    let message: String
    
    init(time: String, message: String) {
        self.time = time
        self.message = message
    }
}
