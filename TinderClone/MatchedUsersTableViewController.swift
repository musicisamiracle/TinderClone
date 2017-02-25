//
//  MatchedUsersTableViewController.swift
//  TinderClone
//
//  Created by Dane Thomas on 1/1/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class MatchedUsersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var matchedUserTable: UITableView!
    var currentUser: PFUser!
    var matchedUsers: [PFUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.current()!
        guard let acceptedUserIDs = currentUser["accepted"] as? Array<String> else {
            print("no accepted users")
            return
        }

        let query = PFUser.query()
        query?.whereKey("objectId", containedIn: acceptedUserIDs)
        query?.findObjectsInBackground(block: { [unowned self] (objects, error) in
            if error != nil {
                print(error.debugDescription)
            }
            
            if let users = objects as? [PFUser] {
                for user in users {
                    if let fetchedUserAcceptedIDs = user["accepted"] as? Array<String> {
                        if fetchedUserAcceptedIDs.contains(self.currentUser.objectId!) {
                            self.matchedUsers.append(user)
                        }
                    }
                }
                self.matchedUserTable.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matchedUsers.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchesCell", for: indexPath) as! MatchedUserTableViewCell
        let user = matchedUsers[indexPath.row]
        cell.sendButton.addTarget(self, action: #selector(sendMessage(_:)), for: .touchUpInside)
        
        let imageFile = user["profileImage"] as! PFFile
        imageFile.getDataInBackground { (data, error) in
            if let data = data {
                cell.userImage.image = UIImage(data: data)
            }
        }
        getMessage(fromUser: user, forCell: cell)
        cell.userNameLabel.text = user["username"] as? String

        

        return cell
    }

    func sendMessage(_ sender: UIButton) {

        let buttonPoint = sender.convert(CGPoint(x: 0, y: 0), to: self.matchedUserTable)
        guard let cellIndexPath = self.matchedUserTable.indexPathForRow(at: buttonPoint) else {
            print("could not get indexPath")
            return
        }
        guard let cell = self.matchedUserTable.cellForRow(at: cellIndexPath) as? MatchedUserTableViewCell else {
            print("could not convert cell to MatchedUserTableViewCell")
            return
        }
        // could use a check for empty textfield
         let newMessage = PFObject(className: "Messages")
         newMessage["sender"] = PFUser.current()
         newMessage["receiver"] = matchedUsers[cellIndexPath.row]
         newMessage["message"] = cell.messageTextField.text
         
         newMessage.saveInBackground { (success, error) in
             if success {
                 print("message Sent")
                 cell.messageTextField.text = ""
             }
         }
     }
    
    func getMessage(fromUser user: PFUser, forCell cell: MatchedUserTableViewCell) {
        let query = PFQuery(className: "Messages")
        query.includeKey("sender")
        query.includeKey("receiver")
        query.whereKey("sender", equalTo: user)
        query.whereKey("receiver", equalTo: currentUser)
        query.limit = 1
        query.addDescendingOrder("createdAt")
        
        query.findObjectsInBackground { (objects, error) in
            if let message = objects {
                cell.messageLabel.text = (message[0]["message"] as! String)
            }
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
