//
//  ViewControllerRegister.swift
//  Planet Pong
//
//  Created by Mac on 8/28/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import Firebase

class ViewControllerRegister: SpaceVibe, UITextFieldDelegate {
    
    var email = ""
    var password = ""
    var username = ""
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        emailField.delegate = self
        passwordField.delegate = self
        passwordField.isSecureTextEntry = true
        passwordField.placeholder = "Password"
        emailField.placeholder = "Email"
        emailField.keyboardType = UIKeyboardType.emailAddress
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide() {
        email = emailField.text!
        password = passwordField.text!
        username = usernameField.text!
    }

    @IBAction func pressRegister(_ sender: Any) {
        if (email != "" && password != "" && email.contains("@") && username != "") {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("New user made!")
                    
                    self.ref.child("data/users").updateChildValues(["\(Auth.auth().currentUser!.uid)":["Username":self.username]])
                    
                    self.fadeOutAnimationPopTo(vc: self.navigationController!.viewControllers[0])
                }
            }
        } else {
            print("Please input a valid email and password")
        }
    }
}
