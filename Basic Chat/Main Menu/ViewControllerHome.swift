//
//  ViewControllerHome.swift
//  Planet Pong
//
//  Created by Mac on 6/9/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerHome: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var startButton: UIButton! //Takes you to the pairing screen
    @IBOutlet weak var scoreButton: UIButton! //Takes you to the scores screen
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    //MARK: Actions
    @IBAction func goToPairing(_ sender: Any) {
        
        print("Go to pairing screen")
        
        //Code to switch screens
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let uartViewController = storyboard.instantiateViewController(withIdentifier: "BLECentralViewController") as! BLECentralViewController
        
        navigationController?.pushViewController(uartViewController, animated: true)
    }
    
    @IBAction func goToScores(_ sender: Any) {
        //TODO - make it go to the scores screen
    }
    
}
