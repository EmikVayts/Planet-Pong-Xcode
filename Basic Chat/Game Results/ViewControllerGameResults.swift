//
//  ViewControllerGameResults.swift
//  Planet Pong
//
//  Created by Mac on 6/10/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

//TODO: Bennett

import Foundation
import UIKit



class ViewControllerGameResults : UIViewController {
    
    //Gamemode that was played
    @IBOutlet weak var gamemode: UILabel!
    
    
    //Players names that will be updated with input names from settings screen
    @IBOutlet weak var player1: UILabel!
    @IBOutlet weak var player2: UILabel!
    @IBOutlet weak var player3: UILabel!
    @IBOutlet weak var player4: UILabel!
    
    //Player One stats
    @IBOutlet weak var player1Acc: UILabel!
    @IBOutlet weak var player1Perc: UILabel!
    @IBOutlet weak var player1Time: UILabel!
    
    //Player Two stats
    @IBOutlet weak var player2Acc: UILabel!
    
    //Player Three stats
    @IBOutlet weak var player3Acc: UILabel!
    
    //Player Four stats
    @IBOutlet weak var player4Acc: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    @IBAction func goToAds(_ sender: Any) {
        print("Go to ads screen")
        
        let storyboard = UIStoryboard(name: "Ads", bundle: nil)
        
        let uartViewController = storyboard.instantiateViewController(withIdentifier: "BLECentralViewController") as! BLECentralViewController
        
        navigationController?.pushViewController(uartViewController, animated: true)
    }

}
