//
//  PostService.swift
//  Remember Me
//
//  Created by Alan Xiao on 7/18/17.
//  Copyright © 2017 Alan Xiao. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator
import SwiftyJSON
import Firebase
import FirebaseStorageUI

struct PostService {
  
    static let dateFormatter = ISO8601DateFormatter()
    static var imageData: UIImage?
    //static let uid = User.current.uid
    static var timestamp = dateFormatter.string(from: Date())
    static var returnImageReal: UIImage?
    static var timestampTwo: String?
    static var urlArray = [String]()
    
    
    
    
    
    static func create(for image: UIImage) {
        let imageRef = Storage.storage().reference().child("images/posts/\(User.current.uid)/\(timestamp).jpg")
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlStr = downloadURL.absoluteString
            let aspectHeight = image.aspectHeight
            create(forURLString: urlStr, aspectHeight: aspectHeight)
            print("image url: \(urlStr)")
            
            
            Alamofire.request("https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=false&returnFaceLandmarks=false", method: .post, parameters: ["url": urlStr, "Content-Type": "application/json"], encoding: JSONEncoding.default, headers: ["Ocp-Apim-Subscription-Key": "49e88c64ac624c5eb0496ed7ae5d6863"]).validate().responseJSON{(response) in
                var widthArray = [Int]()
                var topArray = [Int]()
                var leftArray = [Int]()
                var heightArray = [Int]()

                if let value = response.result.value{
                    let json = JSON(value)
                    if json[0]["faceRectangle"]["top"].stringValue == "" {
                        print("No face detected")
                    } else{
                        
                        
                        for i in 0...json.count-1{
                            widthArray.append(json[i]["faceRectangle"]["width"].intValue)
                            topArray.append(json[i]["faceRectangle"]["top"].intValue)
                            leftArray.append(json[i]["faceRectangle"]["left"].intValue)
                            heightArray.append(json[i]["faceRectangle"]["height"].intValue)
                        }
                        print("widths: \(widthArray)")
                        print("tops: \(topArray)")
                        print("lefts: \(leftArray)")
                        print("heights: \(heightArray)")
                    }
                    
                } else {
                    print("error")
                }
                let imageRef = Storage.storage().reference(forURL: "gs://remember-me-b5786.appspot.com/images/posts/\(User.current.uid)").child("\(timestamp).jpg")
                self.download(ref: imageRef, completion: { (image) in
                    if let image = image {
                        if let returnImage = imageData {
                            let returnImageTwo = drawRectangle(image: returnImage, widthArray: widthArray, heightArray: heightArray, leftArray: leftArray, topArray: topArray)
                            let returnImageThree = numbersOnImage(image: returnImageTwo, widthArray: widthArray, heightArray: heightArray, leftArray: leftArray, topArray: topArray)
                            returnImageReal = returnImageThree
                            print("hi")
                        }
                        else {
                            print ("nil")
                        }
                        //let imageRefTwo = Storage.storage().reference().child("images/posts/\(uid)/\(timestamp).jpg")
                        timestamp = dateFormatter.string(from: Date())
                        let databaseRefTwo = Database.database().reference().child("posts_boxed").child(User.current.uid).child(timestamp)
                        if let returnDaRealImage = returnImageReal{
                            PostService.uploadImage(returnDaRealImage, at: imageRef){ (downloadURL) in
                                guard let downloadURL = downloadURL else {
                                    return
                                }
                                let urlStrTwo = downloadURL.absoluteString
                                let aspectHeight = image.aspectHeight
                                //create(forURLString: urlStrTwo, aspectHeight: aspectHeight)
                                databaseRefTwo.updateChildValues(["url": urlStrTwo, "names": ""], withCompletionBlock: { (error, ref) in
                                    if error != nil {
                                        return
                                    }
                                })
                                print("image url: \(urlStrTwo)")
                            }
                        }else{
                            print("returnImageReal is nil")
                        }

                    }
                })
                
            }
           
        }

        
    }
    
    
    static func download(ref: StorageReference , completion: @escaping (UIImage?) -> ()) {
        let imageURL = Storage.storage().reference(forURL: "gs://remember-me-b5786.appspot.com/images/posts/\(User.current.uid)").child("\(timestamp).jpg")
        imageURL.downloadURL(completion: { (url, error) in
            if error != nil {
                print(error!)
                return
            }
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error.debugDescription)
                    completion(nil)
                    return
                }
                imageData = UIImage(data: data!)
                completion(imageData)
            }).resume()
        })
    }
    
    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        let currentUser = User.current
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        
        // 1
        let rootRef = Database.database().reference()
        let newPostRef = rootRef.child("posts").child(currentUser.uid).childByAutoId()
        let newPostKey = newPostRef.key
        
        // 2
        UserService.followers(for: currentUser) { (followerUIDs) in
            // 3
            let timelinePostDict = ["poster_uid" : currentUser.uid]
            
            // 4
            var updatedData: [String : Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            // 5
            for uid in followerUIDs {
                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
            }
            
            // 6
            let postDict = post.dictValue
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            
            // 7
            rootRef.updateChildValues(updatedData)
        }
    }
//    private static func createTwo(forURLString urlString: String, aspectHeight: CGFloat) {
//        let currentUser = User.current
////        let postBoxed = PostBoxed(imageURL: urlString, imageHeight: aspectHeight)
//        
//        // 1
//        let rootRef = Database.database().reference()
//        let newPostRef = rootRef.child("posts_boxed").child(currentUser.uid).childByAutoId()
//        let newPostKey = newPostRef.key
//        UserService.followers(for: currentUser) { (followerUIDs) in
//            // 3
//            let timelinePostDict = ["poster_uid" : currentUser.uid]
//            
//            // 4
//            var updatedData: [String : Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
//            
//            // 5
//            for uid in followerUIDs {
//                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
//            }
//            
//            // 6
//            let postDict = post.dictValue
////            let postDict = postBoxed.dictValue
//            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
//            
//            // 7
//            rootRef.updateChildValues(updatedData)
//        }
//
//        
//        // 2
//    }

    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = Database.database().reference().child("posts").child(posterUID).child(postKey)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else {
                return completion(nil)
            }
            
            LikeService.isPostLiked(post) { (isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
    
//    static func drawRect(image: UIImage) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(image.size, true, 0)
//        image.draw(at: CGPoint(x: 0,y: 0))
//        let p = UIBezierPath()
//        p.move(to: CGPoint(x: leftArray[0],y: topArray[0]))
//        p.addLine(to: CGPoint(x: leftArray[0]+widthArray[0], y: topArray[0]))
//        p.addLine(to: CGPoint(x: leftArray[0]+widthArray[0], y: topArray[0]+heightArray[0]))
//        p.addLine(to: CGPoint(x: leftArray[0], y: topArray[0]+heightArray[0]))
//        p.addLine(to: CGPoint(x: leftArray[0],y: topArray[0]))
//        p.close()
//        p.stroke()
//        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return resultImage!
//    }
    
    static func drawRectangle(image: UIImage, widthArray: Array<Int>, heightArray: Array<Int>, leftArray: Array<Int>, topArray: Array<Int>) -> UIImage {
        let imageSize = image.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        let context = UIGraphicsGetCurrentContext()
        
        image.draw(at: .zero)
        var rectangleArray = [CGRect]()
        if widthArray.count != 0{
            for i in 0...widthArray.count-1{
                rectangleArray.append(CGRect(x: leftArray[i], y: topArray[i], width: widthArray[i], height: heightArray[i]))
            }
        }
        context!.setStrokeColor(UIColor.red.cgColor)
        context!.setLineWidth(10)
        if widthArray.count != 0 {
            for i in 0...rectangleArray.count-1{
                context!.addRect(rectangleArray[i])
            }
        }
        context!.drawPath(using: .stroke)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        // 1
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        // 2
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            // 3
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            // 4
            completion(metadata?.downloadURL())
        })
    }
    
    static func numbersOnImage(image: UIImage, widthArray: Array<Int>, heightArray: Array<Int>, leftArray: Array<Int>, topArray: Array<Int>) -> UIImage {
        if widthArray.count != 0 {
            var a = leftArray
            print(a)
            for x in 1..<a.count {
                var y = x
                let temp = a[y]
                while y > 0 && temp < a[y - 1] {
                    a[y] = a[y - 1]                // 1
                    y -= 1
                }
                a[y] = temp                      // 2
            }
            print(a)
            let textColor = UIColor.white
            let textFont = UIFont(name: "Helvetica", size: 60)!
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
            
            let textFontAttributes = [
                NSFontAttributeName: textFont,
                NSForegroundColorAttributeName: textColor,
                ] as [String : Any]
            image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
            
            for i in 0...a.count-1{
                let point = CGPoint(x: a[i], y: topArray[i]-60)
                let rect = CGRect(origin: point, size: image.size)
                "\(i+1)".draw(in: rect, withAttributes: textFontAttributes)
            }
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        } else{
            return image
        }
    }
}

    

