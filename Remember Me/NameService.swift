//
//  NameService.swift
//  Remember Me
//
//  Created by Alan Xiao on 8/7/17.
//  Copyright © 2017 Alan Xiao. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct NameService {
    static func create(for post: Post, success: @escaping (Bool) -> Void) {
        // 1
        guard let key = post.key else {
            return success(false)
        }
        
        // 2
        let currentUID = User.current.uid
        
        // 3 code to like a post
        let namesRef = Database.database().reference().child("postNames").child(key).child(currentUID)
        namesRef.setValue(true) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            return success(true)
        }
    }
}
