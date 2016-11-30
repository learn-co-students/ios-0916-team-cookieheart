//
//  Temp.swift
//  emeraldHail
//
//  Created by Henry Ly on 11/29/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation

struct Temp {
    
    var content: String
    var timestamp: String
    
    init(dictionary: [String : Any]) {
        
        content = dictionary["content"] as? String ?? "No Content"
        timestamp = dictionary["timeStamp"] as? String ?? "No Time"
        
        
    }
    
    init(content: String, timestamp: String) {
        print("Creating an instance of Temp")
        
        self.content = content
        self.timestamp = timestamp
        
    }
    
    func serialize() -> [String : Any] {
        print("Serializing a Temp")
        
        return ["content" : content,
                "timestamp" : timestamp,
                "postType" : "temp"]
    }
    
}
