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
    
    @IBAction func goToScores(_ sender: Any) {
        //TODO - make it go to the scores screen
        /*let storyboard = UIStoryboard(name: "Tutorial", bundle: Bundle.main)
        
        guard let uartViewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerTutorial") as?
            ViewControllerTutorial else {
            return
        }
        
        navigationController?.pushViewController(uartViewController, animated: true)*/
    }
    
}
