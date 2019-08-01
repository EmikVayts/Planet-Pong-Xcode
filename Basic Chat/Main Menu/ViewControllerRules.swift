//
//  ViewControllerRules.swift
//  Planet Pong
//
//  Created by Mac on 7/21/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerRules: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    
    @IBAction func `return`(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
}
