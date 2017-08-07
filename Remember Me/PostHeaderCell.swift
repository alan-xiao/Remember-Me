//
//  PostHeaderCell.swift
//  Remember Me
//
//  Created by Alan Xiao on 7/21/17.
//  Copyright © 2017 Alan Xiao. All rights reserved.
//

import Foundation
import UIKit

class PostHeaderCell: UITableViewCell {
    @IBOutlet weak var optionsButton: UIButton!
    var didTapOptionsButtonForCell: ((PostHeaderCell) -> Void)?
    static let height: CGFloat = 54
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        print("options button tapped")
        didTapOptionsButtonForCell?(self)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
