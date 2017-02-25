//
//  ProfileViewController.swift
//  TinderClone
//
//  Created by Dane Thomas on 12/22/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let currentUser: PFUser = PFUser.current()!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var genderSwitch: UISwitch!
    @IBOutlet var interestedSwitch: UISwitch!

    @IBAction func logOut(_ sender: UIBarButtonItem) {
        PFUser.logOut()

        performSegue(withIdentifier: "toLogIn", sender: self)
    }
    
    @IBAction func updateProfileImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = selectedImage
            
            if let imageAsData = UIImageJPEGRepresentation(selectedImage, 1) {
                let imageFile = PFFile(name: "photo.jpg", data: imageAsData)
                
                currentUser["profileImage"] = imageFile
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateProfile(_ sender: Any) {
        currentUser["gender"] = genderSwitch.isOn ? "female" : "male"
        currentUser["interestedGender"] = interestedSwitch.isOn ? "female" : "male"
        currentUser.saveInBackground()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userImage = currentUser["profileImage"] as? PFFile {
            userImage.getDataInBackground(block: { [unowned self] (data, error) in
                if error != nil {
                    print(error.debugDescription)
                    self.createAlert(title: "Image Download Error", message: "Unable to download image.")
                    return
                }
                
                guard let data = data else {
                    self.createAlert(title: "Image Download Error", message: "Unable to download image.")
                    return
                }
                
                if let imageFromData = UIImage(data: data) {
                    self.profileImage.image = imageFromData
                }
            })
        }
        
        if let gender = currentUser["gender"] as? String {
            genderSwitch.isOn = (gender == "female") ? true : false

        }
        
        if let interestedGender = currentUser["interestedGender"] as? String {
            interestedSwitch.isOn = (interestedGender == "female") ? true : false

        }
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
