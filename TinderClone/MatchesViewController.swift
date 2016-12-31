//
//  MatchesViewController.swift
//  TinderClone
//
//  Created by Dane Thomas on 12/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

/* need to query Matches to find users who have already been swiped, then don't display them.*/

class MatchesViewController: UIViewController {

    @IBOutlet var userImage: UIImageView!
    var originalCenterX: CGFloat!
    var originalCenterY: CGFloat!
    var currentUser: PFUser!
    var displayedUserID: String = ""
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        performSegue(withIdentifier: "toLogIn", sender: self)
    }
    
    func imageSwiped(gestureRecognizer: UIPanGestureRecognizer) {
        let image = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: self.view)
        
        image.center = CGPoint(x: originalCenterX + translation.x, y: originalCenterY + translation.y)
        
        let distFromCenterX = image.center.x - self.view.bounds.width / 2
        var rotation = CGAffineTransform(rotationAngle: distFromCenterX / 200)
        let scale = min(abs(50 / distFromCenterX), 1)
        var rotateAndScale = rotation.scaledBy(x: scale, y: scale)
        image.transform = rotateAndScale
        
        if gestureRecognizer.state == .ended {
            
            var acceptedOrRejected = ""
            if image.center.x < 100 {
                print("rejected")
                acceptedOrRejected = "rejected"
            }
            else if image.center.x > self.view.bounds.width - 100 {
                print("accepted")
                acceptedOrRejected = "accepted"
            }
            else {
                print("no selection")
                print(displayedUserID)
                return
            }
            
            if displayedUserID != "" && acceptedOrRejected != "" {
                currentUser.addUniqueObject(displayedUserID, forKey: acceptedOrRejected)
                currentUser.saveInBackground()
                showNextUser()
            }
            
            image.center = CGPoint(x: originalCenterX, y: originalCenterY)
            rotation = CGAffineTransform(rotationAngle: 0)
            rotateAndScale = rotation.scaledBy(x: 1, y: 1)
            image.transform = rotateAndScale
            
        }
        
        
    }

    
    func showNextUser() {

        let userQuery = PFUser.query()
        
        userQuery?.whereKey("gender", equalTo: currentUser["interestedGender"]!)
        userQuery?.whereKey("interestedGender", equalTo: currentUser["gender"]!)
        userQuery?.limit = 1
        
        var ignoredUsers: [String] = []
        
        if let acceptedUsers = currentUser["accepted"] {
            ignoredUsers += acceptedUsers as! Array
        }
        
        if let rejectedUsers = currentUser["rejected"] {
            ignoredUsers += rejectedUsers as! Array
        }
        
        userQuery?.whereKey("objectId", notContainedIn: ignoredUsers)
        
        userQuery?.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error.debugDescription)
            }
            
            if objects?.count == 0 {
                self.createAlert(title: "Out of Users", message: "There are no more users to show")
                return
            }
            if let userObjects = objects as? [PFUser] {
                self.displayedUserID = userObjects[0].objectId!
                
                self.displayPhoto(forUser: userObjects[0])
            }
        }
    }

    func displayPhoto(forUser user: PFUser) {
        
        if let imageFile = user["profileImage"] as? PFFile {
            imageFile.getDataInBackground(block: { (data, error) in
                if error != nil {
                    print(error.debugDescription)
                }
                
                if let data = data {
                    let image = UIImage(data: data)
                    self.userImage.image = image
                }
            })
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalCenterX = userImage.center.x
        originalCenterY = userImage.center.y
        
        currentUser = PFUser.current()
        
        showNextUser()
        
        
        
        userImage.isUserInteractionEnabled = true
        let swipeRecognizer = UIPanGestureRecognizer(target: self, action: #selector(imageSwiped(gestureRecognizer:)))
        
        userImage.addGestureRecognizer(swipeRecognizer)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
