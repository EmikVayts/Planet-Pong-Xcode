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
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var hallOfFameButton: UIButton!
    
    @IBOutlet weak var purpleFadeBackground: UIImageView!
    @IBOutlet weak var starsBackground: UIImageView!
    
    var timer = Timer()
    var xPos = 0
    
    var starsAlpha = 0.5
    var alphaDir = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
        
        xPos = 0
        
        startButton.layer.borderColor = UIColor.white.cgColor;
        startButton.layer.borderWidth = 3;
        startButton.layer.cornerRadius = 3;
        
        scoreButton.layer.borderColor = UIColor.white.cgColor;
        scoreButton.layer.borderWidth = 3;
        scoreButton.layer.cornerRadius = 3;
        
        howToPlayButton.layer.borderColor = UIColor.white.cgColor;
        howToPlayButton.layer.borderWidth = 3;
        howToPlayButton.layer.cornerRadius = 3;
        
        hallOfFameButton.layer.borderColor = UIColor.white.cgColor;
        hallOfFameButton.layer.borderWidth = 3;
        hallOfFameButton.layer.cornerRadius = 3;
        
        /*starsBackground.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)*/
        starsAlpha = 0.5
        alphaDir = 0
        
    }
    
    @objc func updateCounter() {
        if (alphaDir == 0) {
            starsAlpha += 0.01
            purpleFadeBackground.alpha = CGFloat(starsAlpha)
            if (starsAlpha>=1) {
                alphaDir = 1
            }
            
        } else {
            starsAlpha -= 0.01
            purpleFadeBackground.alpha = CGFloat(starsAlpha)
            if (starsAlpha<=0.5) {
                alphaDir = 0
            }
            
        }
        /*xPos = xPos+10
        starsBackground.center = CGPoint(x: ((self.view.frame.width/2)+CGFloat(xPos)), y: self.view.frame.height/2)*/
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
