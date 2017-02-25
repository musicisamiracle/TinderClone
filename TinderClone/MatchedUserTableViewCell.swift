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
    @IBOutlet var sendButton: UIButton!

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
