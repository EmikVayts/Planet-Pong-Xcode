//
//  ViewControllerHallOfFame.swift
//  Planet Pong
//
//  Created by Mac on 7/28/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerHallOfFame: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        backButton.layer.borderColor = UIColor.white.cgColor;
        backButton.layer.borderWidth = 3;
        backButton.layer.cornerRadius = 3;
        
    }
    

    @IBAction func `return`(_ sender: Any) {
        let screenTransition = ScreenTransitions()
        
        screenTransition.popScreen(nc: navigationController!)
        
    }
    
}
