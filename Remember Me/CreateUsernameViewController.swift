//
//  CreateUsernameViewController.swift
//  Remember Me
//
//  Created by Alan Xiao on 7/19/17.
//  Copyright © 2017 Alan Xiao. All rights reserved.
//

//import Foundation
//import UIKit
//import FirebaseAuth
//import FirebaseDatabase
//
//class CreateUsernameViewController: UIViewController {
//    @IBOutlet weak var usernameTextField: UITextField!
//    @IBOutlet weak var nextButton: UIButton!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    @IBAction func nextButtonTapped(_ sender: UIButton) {
//        guard let firUser = Auth.auth().currentUser,
//            let username = usernameTextField.text,
//            !username.isEmpty else { return }
//        
//        UserService.create(firUser, username: username) { (user) in
//            guard let _ = user else {
//                return
//            }
//            
//            User.setCurrent(user!)
//            
//            let storyboard = UIStoryboard(name: "Main", bundle: .main)
//            
//            if let initialViewController = storyboard.instantiateInitialViewController() {
//                self.view.window?.rootViewController = initialViewController
//                self.view.window?.makeKeyAndVisible()
//            }
//        }
//        
//        UserService.create(firUser, username: username) { (user) in
//            guard let user = user else {
//                // handle error
//                return
//            }
//            
//            User.setCurrent(user, writeToUserDefaults: true)
//            
//            let initialViewController = UIStoryboard.instantiateViewController(for: .main)
//            self.view.window?.rootViewController = initialViewController
//            self.view.window?.makeKeyAndVisible()
//        }
//    
//    }
//}


//
//  CreateUsernameViewController.swift
//  Makestagram
//
//  Created by Alan Xiao on 6/26/17.
//  Copyright © 2017 Alan Xiao. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUsernameViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let firUser = Auth.auth().currentUser,
            let username = usernameTextField.text,
            !username.isEmpty else { return }
        
        UserService.create(firUser, username: username) { (user) in
            guard let user = user else { return }
            
            print("Created new user: \(user.username)")
        }
        
        UserService.create(firUser, username: username) { (user) in
            guard let user = user else {
                // handle error
                return
            }
            
            User.setCurrent(user, writeToUserDefaults: true)
            
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
}
