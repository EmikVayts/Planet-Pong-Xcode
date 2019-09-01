//
//  ViewControllerBluetoothMode.swift
//  Planet Pong
//
//  Created by Mac on 8/29/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerBluetoothMode: SpaceVibe {

    @IBOutlet weak var pairWithMachine: UIButton!
    @IBOutlet weak var pairWithoutMachine: UIButton!
    
    @IBAction func backButton(_ sender: Any) {
        fadeOutAnimationPop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pairWithMachine.layer.borderColor = UIColor.white.cgColor;
        pairWithMachine.layer.borderWidth = 1;
        pairWithMachine.layer.cornerRadius = 3;
        
        pairWithoutMachine.layer.borderColor = UIColor.white.cgColor;
        pairWithoutMachine.layer.borderWidth = 1;
        pairWithoutMachine.layer.cornerRadius = 3;
    }
    
    @IBAction func pairWithMachinePressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Pairing", bundle: Bundle.main)
        
        let newViewController = (storyboard.instantiateViewController(withIdentifier: "ViewControllerPairing") as?
            ViewControllerPairing)!
        
        fadeOutAnimationPush(vc: newViewController)
    }
    
    @IBAction func pairWithoutMachinePressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "GameSettings", bundle: Bundle.main)
        
        let newViewController = (storyboard.instantiateViewController(withIdentifier: "ViewControllerGameSettings") as?
            ViewControllerGameSettings)!
        
        fadeOutAnimationPush(vc: newViewController)
    }
}
