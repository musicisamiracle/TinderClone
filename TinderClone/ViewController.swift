/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {
    
    var signUpMode = false
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var signUpOrLogIn: UIButton!
    
    @IBOutlet var signUpModeButton: UIButton!
    
    @IBOutlet var messageLabel: UILabel!
    
    @IBAction func signUpOrLogIn(_ sender: UIButton) {
        if usernameTextField.text == "" || passwordTextField.text == "" {
            createAlert(title: "Invalid email/password", message: "Please enter a valid email address and password")
            return
        }
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        if signUpMode {
            // signing up
            
            let user = PFUser()
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            
            
            user.signUpInBackground(block: { (success, error) in
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
                
                if success {
                    print("Sign up successful!")
                    self.performSegue(withIdentifier: "toUserTable", sender: self)
                }
                else {
                    var message = "Please try again later"
                    if let errorMessage = (error as! NSError).userInfo["error"] as? String {
                        message = errorMessage
                    }
                    PFUser.logOut()
                    self.createAlert(title: "Parse Error", message: message)
                }
            })
        }
        else {
            // logging in
            
            PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
                
                if error != nil {
                    self.createAlert(title: "Login failed", message: "Invalid username/password")
                }
                else {
                    self.performSegue(withIdentifier: "toUserTable", sender: self)
                }
            })
        }
        
    }
    
    @IBAction func changeMode(_ sender: UIButton) {
        
        if signUpMode {
            signUpOrLogIn.setTitle("Log in", for: [])
            signUpModeButton.setTitle("Sign up", for: [])
            messageLabel.text = "Not a member?"
            signUpMode = false
        }
        else {
            signUpOrLogIn.setTitle("Sign up", for: [])
            signUpModeButton.setTitle("Log in", for: [])
            messageLabel.text = "Already signed up?"
            signUpMode = true
        }
        
    }
        

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(activityIndicator)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewController {
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
