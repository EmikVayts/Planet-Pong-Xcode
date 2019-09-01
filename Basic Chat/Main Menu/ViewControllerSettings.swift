//
//  ViewControllerSettings.swift
//  Planet Pong
//
//  Created by Mac on 8/24/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerSettings: SpaceVibe {
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //backButton.layer.borderColor = UIColor.white.cgColor;
        //backButton.layer.borderWidth = 3;
        //backButton.layer.cornerRadius = 3;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Configure Firebase authentication
        //handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            // ...
        //}
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        //let authUI = FUIAuth.defaultAuthUI()
        
        //guard authUI != nil else {
        //    return
        //}
        
        //authUI?.delegate = self
        
        //let authViewController = authUI!.authViewController()
        let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
        guard let newViewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerRegister") as?
            ViewControllerRegister else {
                return
        }
        
        fadeOutAnimationPush(vc: newViewController)
    }
    
    @IBAction func `return`(_ sender: Any) {
        fadeOutAnimationPop()
    }
}

/*extension SpaceVibe: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?,error: Error?) {
        guard error == nil else {
            return
        }
        
        //authDataResult?.user.uid
    }
}*/
