//
//  ViewControllerScores.swift
//  Planet Pong
//
//  Created by Matthew Vayts on 6/9/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerScores: UIViewController {
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func goToClassicScores(_ sender: Any) {
        //Code to switch screens
        let storyboard = UIStoryboard(name: "ClassicScores", bundle: nil)
        
        let uartViewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerClassicScores") as! ViewControllerClassicScores
        
        navigationController?.pushViewController(uartViewController, animated: true)
    }

   
    
    
    
        

}
