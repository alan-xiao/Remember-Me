////
////  User.swift
////  Remember Me
////
////  Created by Alan Xiao on 7/19/17.
////  Copyright © 2017 Alan Xiao. All rights reserved.
////
//
//import FirebaseDatabase.FIRDataSnapshot
//import Foundation
//
//class User: NSObject {
//    
//    // MARK: - Properties
//    
//    let uid: String
//    let username: String
//    
//    private static var _current: User?
//    
//    static var current: User {
//        // 3
//        guard let currentUser = _current else {
//            fatalError("Error: current user doesn't exist")
//        }
//        
//        // 4
//        return currentUser
//    }
//    
//    // MARK: - Class Methods
//    
//    // 5
//    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
//        // 2
//        if writeToUserDefaults {
//            // 3
//            let data = NSKeyedArchiver.archivedData(withRootObject: user)
//            
//            // 4
//            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
//        }
//        
//        _current = user
//    }
//    // MARK: - Init
//    
//    init(uid: String, username: String) {
//        self.uid = uid
//        self.username = username
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
//            let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String
//            else { return nil }
//        
//        self.uid = uid
//        self.username = username
//        
//        super.init()
//    }
//    
//    init?(snapshot: DataSnapshot) {
//        guard let dict = snapshot.value as? [String : Any],
//            let username = dict["username"] as? String
//            else { return nil }
//        
//        self.uid = snapshot.key
//        self.username = username
//    }
//}
//
//extension User: NSCoding {
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
//        aCoder.encode(username, forKey: Constants.UserDefaults.username)
//    }
//}


import Foundation
import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    
    // MARK: - Properties
    
    let uid: String
    let username: String
    var isFollowed = false
    
    // MARK: - Init
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String
            else { return nil }
        
        self.uid = uid
        self.username = username
        
        super.init()
    }
    
    // MARK: - Singleton
    
    // 1
    private static var _current: User?
    
    // 2
    static var current: User {
        // 3
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        // 4
        return currentUser
    }
    
    // MARK: - Class Methods
    
    // 5
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        // 2
        if writeToUserDefaults {
            // 3
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            
            // 4
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }
        
        _current = user
    }
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
        aCoder.encode(username, forKey: Constants.UserDefaults.username)
    }
}
