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
    static var nameString: String?
    let refreshControl = UIRefreshControl()
    var posts = [Post]()
    var postURLS = [String]()
    var nameArray: Array<String> = [] {
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
        UserService.postsBoxed { (stringArray) in
            self.postURLS = stringArray
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let postURL = postURLS[indexPath.section]
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostHeaderCell") as! PostHeaderCell
            cell.usernameLabel.text = post.poster.username
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
            if let name = HomeViewController.nameString {
                cell.nameLabel.text = nameArray[0]
            }else{
                //do nothing
            }
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostActionCell") as! PostActionCell
            cell.delegate = self
            configureCell(cell, with: post)
            
            return cell
            
        default:
            fatalError("Error: unexpected indexPath.")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return postURLS.count
    }
    
    func configureCell(_ cell: PostActionCell, with post: Post) {
        cell.timeAgoLabel.text = timestampFormatter.string(from: post.creationDate)
        cell.likeButton.isSelected = post.isLiked
        cell.likeCountLabel.text = "\(post.likeCount) likes"
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
                    UserDefaults.standard.set(field.text, forKey: "name")
                    HomeViewController.nameString = field.text
                    self.nameArray = HomeViewController.parseString(nameString: HomeViewController.nameString!)
//                    let ref = Database.database().reference().child("names/\(User.current.uid)")
//                    ref.setValue(self.nameArray)
                    UserDefaults.standard.synchronize()
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
    
    static func parseString(nameString: String) -> Array<String>{
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
