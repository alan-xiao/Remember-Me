//
//  HomeViewController.swift
//  Remember Me
//
//  Created by Alan Xiao on 7/21/17.
//  Copyright © 2017 Alan Xiao. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Firebase
import FirebaseDatabase
import FirebaseStorage
import CoreGraphics
import FirebaseAuthUI

class HomeViewController: UIViewController{
    var timestamp = ""
    static var nameString: String?
    let refreshControl = UIRefreshControl()
    var posts = [Post]()
    //var postURLS = [String]()
    var postBoxedArray = [PostBoxed]()
    static var nameArray: Array<String> = [] {
        didSet{
            print(nameArray)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        UserService.posts(for: User.current) { (posts) in
//            self.posts = posts
//            self.tableView.reloadData()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        reloadTimeline()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserService.postsBoxed { (postBoxedArray) in
            self.postBoxedArray = postBoxedArray
            print(self.postBoxedArray)
            
            self.reloadTimeline()
        }
        //something inside of here that we want to happen everytime we open this view/view controller
    }
    
    func reloadTimeline() {
        UserService.timeline { (posts) in
            self.posts = posts
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            self.tableView.reloadData()
        }
        
        
    }
    func configureTableView() {
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        // remove separators from cells
        tableView.separatorStyle = .none
        refreshControl.addTarget(self, action: #selector(reloadTimeline), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let postURL = postBoxedArray[indexPath.section].url!
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostHeaderCell") as! PostHeaderCell
            //cell.usernameLabel.text = post.poster.username
            cell.usernameLabel.text = timestampFormatter.string(from: post.creationDate)
            cell.optionsButton.tag = indexPath.section
            cell.didTapOptionsButtonForCell = handleOptionsButtonTap(from:)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostImageCell") as! PostImageCell
            let imageURL = URL(string: postURL)
            cell.postImageView.kf.setImage(with: imageURL)
            //cell.postImageView.image = PostService.imageData
            //cell.postImageView.image = PostService.returnImageReal
            //cell.postImageView.image = PostService.daEXTREMEMETHOD(image: (PostService.imageData!))
            
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell") as! NameCell
//            if let name = HomeViewController.nameString {
//                if HomeViewController.nameArray.count != 0 {
//                    var theString: String = ""
//                    if HomeViewController.nameArray.count == 1{
//                        theString = "1: " + HomeViewController.nameArray[0]
//                        cell.nameLabel.text = theString
//                    } else{
//                        for i in 0...HomeViewController.nameArray.count-1{
//                            theString = theString + "\(i+1): " + HomeViewController.nameArray[i]
//                            if i != HomeViewController.nameArray.count-1{
//                                theString = theString + ", "
//                            }
//                        }
//                        cell.nameLabel.text = theString
//                    }
//                }
//            }else{
//                //do nothing
//            }
            let ref = Database.database().reference().child("posts_boxed").child(User.current.uid).child(self.postBoxedArray[indexPath.section].key!)
            ref.observe(.value, with: { (snapshot) in
                if let snapshot = snapshot.value as? [String: Any] {
                    print(snapshot)
                    cell.nameLabel.text = snapshot["names"] as? String
                }
            })
            return cell
            
//        case 3:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PostActionCell") as! PostActionCell
//            cell.delegate = self
//            configureCell(cell, with: post)
//            
//            return cell
            
        default:
            fatalError("Error: unexpected indexPath.")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return postBoxedArray.count
    }
    
    func configureCell(_ cell: PostActionCell, with post: Post) {
        cell.timeAgoLabel.text = timestampFormatter.string(from: post.creationDate)
        cell.likeButton.isSelected = post.isLiked
        //cell.likeCountLabel.text = "\(post.likeCount) likes"
        cell.likeCountLabel.text = ""
    }
    
    func handleOptionsButtonTap(from cell: PostHeaderCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let post = posts[indexPath.section]
        //let poster = post.poster
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let flagAction = UIAlertAction(title: "Assign Names", style: .default) { _ in
            let alertController = UIAlertController(title: nil, message: "Assign the first and last names of the faces from left to right. Separate each name with a comma with no space.", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                if let field = alertController.textFields?[0] {
                    // store your data
//                    UserDefaults.standard.set(field.text, forKey: "name")
//                    HomeViewController.nameString = field.text
//                    HomeViewController.nameArray = HomeViewController.parseString(nameString: HomeViewController.nameString!)
//                    let ref = Database.database().reference().child("names/\(User.current.uid)")
////                    ref.setValue(self.nameArray)
//                    UserDefaults.standard.synchronize()
                    if let text = field.text {
                        if !field.text!.isEmpty {
                            let ref = Database.database().reference().child("posts_boxed").child(User.current.uid).child(self.postBoxedArray[cell.optionsButton.tag].key!)
                            let nameArray = self.parseString(nameString: text)
                            let theString = self.combineString(nameArray: nameArray)
                            ref.updateChildValues(["names": theString], withCompletionBlock: { (error, ref) in
                                if error != nil {
                                    print(error)
                                }
                            })
                            
                        }
                    }

                    
                } else {
                    // user did not fill field
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            alertController.addTextField { (textField) in
                textField.placeholder = "Names"
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        alertController.addAction(flagAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func parseString(nameString: String) -> Array<String>{
        var tempStr = ""
        var strArray = [String]()
        for character in nameString.characters{
            if character != "," {
                tempStr = tempStr + "\(character)"
            } else {
                strArray.append(tempStr)
                tempStr = ""
            }
        }
        if tempStr != "" {
            strArray.append(tempStr)
        }
        
        print(strArray)
        return strArray
    }
    
    func combineString(nameArray: Array<String>) -> String{
        var theString = ""
        if nameArray.count != 0 {
            if nameArray.count == 1{
                theString = "1: " + nameArray[0]
                return theString
            }else{
                for i in 0...nameArray.count-1{
                    theString = theString + "\(i+1): " + nameArray[i]
                    if i != nameArray.count-1{
                        theString = theString + ", "
                    }
                }
                return theString
            }
        }else{
            return theString
        }
    }
   
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return PostHeaderCell.height
            
        case 1:
            let post = posts[indexPath.section]
            return post.imageHeight
            
        case 2:
            return NameCell.height
        case 3:
            return PostActionCell.height
            
        default:
            fatalError()
        }
    }
}

extension HomeViewController: PostActionCellDelegate {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
        // 1
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        
        // 2
        likeButton.isUserInteractionEnabled = false
        // 3
        let post = posts[indexPath.section]
        
        // 4
        LikeService.setIsLiked(!post.isLiked, for: post) { (success) in
            // 5
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            
            // 6
            guard success else { return }
            
            // 7
            post.likeCount += !post.isLiked ? 1 : -1
            post.isLiked = !post.isLiked
            
            // 8
            guard let cell = self.tableView.cellForRow(at: indexPath) as? PostActionCell
                else { return }
            
            // 9
            DispatchQueue.main.async {
                self.configureCell(cell, with: post)
            }
        }
    }
}
