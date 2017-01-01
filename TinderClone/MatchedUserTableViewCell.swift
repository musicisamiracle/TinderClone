//
//  MatchedUserTableViewCell.swift
//  TinderClone
//
//  Created by Dane Thomas on 1/1/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse


class MatchedUserTableViewCell: UITableViewCell {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var userNameLabel: UILabel!
    var receivingUser: PFUser?
    
    @IBAction func sendMessage(_ sender: Any) {
        let newMessage = PFObject(className: "Messages")
        newMessage["sender"] = PFUser.current()
        newMessage["receiver"] = receivingUser
        newMessage["message"] = messageTextField.text
        
        newMessage.saveInBackground { (success, error) in
            if success {
                print("message Sent")
                self.messageTextField.text = ""
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
