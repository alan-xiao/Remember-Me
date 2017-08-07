//
//  PostBoxed.swift
//  Remember Me
//
//  Created by Alan Xiao on 8/7/17.
//  Copyright © 2017 Alan Xiao. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase.FIRDataSnapshot

class PostBoxed{
    var key: String?
    var names: String?
    var url: String?

    init(key: String, names: String, imageURL: String) {
        self.key = key
        self.names = names
        self.url = imageURL
    }
//    var dictValue: [String : Any] {
//        let createdAgo = creationDate.timeIntervalSince1970
//        
//        return ["image_url" : imageURL,
//                "image_height" : imageHeight,
//                "created_at" : createdAgo]
//    }
}
