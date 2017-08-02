//
//  StorageReference+Post.swift
//  Remember Me
//
//  Created by Alan Xiao on 7/21/17.
//  Copyright © 2017 Alan Xiao. All rights reserved.
//

import Foundation
import FirebaseStorage

extension StorageReference {
    static let dateFormatter = ISO8601DateFormatter()
    static func newPostImageReference() -> StorageReference {
        let uid = User.current.uid
        let timestamp = dateFormatter.string(from: Date())
        return Storage.storage().reference().child("images/posts/\(uid)/\(timestamp).jpg")
        
    }
}
