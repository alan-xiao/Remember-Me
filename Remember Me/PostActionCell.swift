//
//  PostActionCell.swift
//  Remember Me
//
//  Created by Alan Xiao on 7/21/17.
//  Copyright © 2017 Alan Xiao. All rights reserved.
//

import Foundation
import UIKit

protocol PostActionCellDelegate: class {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell)
}

class PostActionCell: UITableViewCell {
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    weak var delegate: PostActionCellDelegate?
    static let height: CGFloat = 46
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.didTapLikeButton(sender, on: self)
    }
   
}
