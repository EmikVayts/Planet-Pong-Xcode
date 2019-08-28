//
//  ViewControllerSettings.swift
//  Planet Pong
//
//  Created by Mac on 8/24/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit
import Firebase

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
    
    @IBAction func `return`(_ sender: Any) {
        fadeOutAnimationPop()
    }
}
