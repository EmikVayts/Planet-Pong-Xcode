//
//  ViewControllerHome.swift
//  Planet Pong
//
//  Created by Mac on 6/9/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

//Initialize the audio player
var audioPlayer = AVAudioPlayer()

class ViewControllerHome: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Properties
    @IBOutlet weak var startButton: UIButton! //Takes you to the pairing screen
    @IBOutlet weak var scoreButton: UIButton! //Takes you to the scores screen
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var hallOfFameButton: UIButton!
    
    @IBOutlet weak var musicButton: UIButton!
    
    var timer = Timer()
    var xPos = 0
    
    var starsAlpha = 0.5
    var alphaDir = 0 //0 is up, 1 is down
    
    var imageView1: UIImageView?
    
    @IBAction func musicButtonPressed(_ sender: Any) {
        if (musicButton.alpha == 1) {
            musicButton.alpha = 0.25
            audioPlayer.setVolume(0.0, fadeDuration: 0)
        } else {
            musicButton.alpha = 1
            audioPlayer.setVolume(1.0, fadeDuration: 0)
        }
    }
    
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        //If theres a song playing set volume to 0, otherwise set volume to 1
        if (AVAudioSession.sharedInstance().isOtherAudioPlaying || musicButton.alpha==0.25) {
            audioPlayer.setVolume(0.0, fadeDuration: 0)
        } else {
            audioPlayer.setVolume(1.0, fadeDuration: 0)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        //Create the stars and purple fade for aesthetic
        let image = UIImage(named: "StarsBackground")
        let imageView = UIImageView(image: image!)
        imageView.frame = self.view.frame
        imageView.layer.zPosition = -100
        view.addSubview(imageView)
        
        let image1 = UIImage(named: "PurpleFadeBackground")?.withRenderingMode(.alwaysTemplate)
        imageView1 = UIImageView(image: image1!)
        imageView1!.tintColor = .purple
        imageView1!.frame = self.view.frame
        view.addSubview(imageView1!)
        
        //Create a notification for when the app comes back into the foreground
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        //Set the audio category to ambient, which will allow us to blend with music from other apps
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }

        //Setup the audio
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "mainMenuSong", ofType: "mp3")!))
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
        } catch {
            print(error)
        }
        
        //Actually play the audio
        audioPlayer.play()
        
        //If theres a song playing set volume to 0, otherwise set volume to 1
        if (AVAudioSession.sharedInstance().isOtherAudioPlaying) {
            audioPlayer.setVolume(0.0, fadeDuration: 0)
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
        
        xPos = 0
        
        startButton.layer.borderColor = UIColor.white.cgColor;
        startButton.layer.borderWidth = 3;
        startButton.layer.cornerRadius = 3;
        startButton.setTitleColor(UIColor.darkGray, for: UIControl.State.highlighted)
        
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
            imageView1!.alpha = CGFloat(starsAlpha)
            if (starsAlpha>=1) {
                alphaDir = 1
            }
            
        } else {
            starsAlpha -= 0.01
            imageView1!.alpha = CGFloat(starsAlpha)
            if (starsAlpha<=0.25) {
                alphaDir = 0
                if (imageView1?.tintColor == .green) {
                    imageView1!.tintColor = .purple
                } else if (imageView1?.tintColor == .purple) {
                    imageView1!.tintColor = .blue
                } else if (imageView1?.tintColor == .blue) {
                    imageView1!.tintColor = .red
                } else if (imageView1?.tintColor == .red) {
                    imageView1!.tintColor = .green
                }
                
            }
            
        }
        /*xPos = xPos+10
        starsBackground.center = CGPoint(x: ((self.view.frame.width/2)+CGFloat(xPos)), y: self.view.frame.height/2)*/
    }
    
    //Action to go to pairing screen
    @IBAction func goToPairing(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Pairing", bundle: Bundle.main)
        
        guard let newViewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerPairing") as?
            ViewControllerPairing else {
                return
        }
        
        let screenTransition = ScreenTransitions()
        screenTransition.pushScreen(vc: newViewController, nc: navigationController!)
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
    
    @IBAction func goToHallOfFame(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: Bundle.main)
        guard let newViewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerHallOfFame") as?
            ViewControllerHallOfFame else {
                return
        }
        
        let screenTransition = ScreenTransitions()
        screenTransition.pushScreen(vc: newViewController, nc: navigationController!)

    }
    
    
}
