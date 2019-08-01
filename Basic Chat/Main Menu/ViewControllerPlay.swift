//
//  ViewControllerPlay.swift
//  Planet Pong
//
//  Created by Mac on 7/31/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerPlay: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    @IBAction func play(_ sender: Any) {
        print("Go to pairing screen")
        
        //Code to switch screens
        let storyboard = UIStoryboard(name: "Pairing", bundle: Bundle.main)
        
        guard let uartViewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerPairing") as?
            ViewControllerPairing else {
                return
        }
        
        //present (uartViewController, animated: true, completion: nil)
        navigationController?.pushViewController(uartViewController, animated: true)
    }
}
