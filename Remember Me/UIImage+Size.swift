//
//  UIImage+Size.swift
//  Remember Me
//
//  Created by Alan Xiao on 7/21/17.
//  Copyright © 2017 Alan Xiao. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    var aspectHeight: CGFloat {
        let heightRatio = size.height / 736
        let widthRatio = size.width / 414
        let aspectRatio = fmax(heightRatio, widthRatio)
        
        return size.height / aspectRatio
    }
}
