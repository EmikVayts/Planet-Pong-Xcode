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
var sfxPlayer = AVAudioPlayer()
var musicToggle = true

class ViewControllerHome: SpaceVibe {
    
    let motdMessages = ["MUSIC BY DORM ROOM STUDIOS!", "MADE IN THE USA!", "TEAM USA!", "ON WISCONSIN!", "BUCKS IN 6!", "JUMP AROUND!", "GO PACK GO!", "BREW CREW!", "MADE BY COLLEGE STUDENTS!", "PARTY TIME!", "LET'S GET IT!", "BEAST MODE!", "GOAT STATUS!", "FULLY YOITED!", "GAMEDAY!", "GAME TIME!", "THAT ASS WAS FAT!", "OH MY YAK!", "TURN UP THE BASS!", "HAMMER TIME!", "DON'T DRINK AND DRIVE!", "ALWAYS WEAR PROTECTION!", "NO DETOX TONIGHT!", "HIT ME BABY ONE MORE TIME!", "TEACH ME HOW TO DOUGIE!", "YOU'RE A RICH GIRL!", "STRAIGHT OUTTA WISCOMPTON!", "DRINK WISCONSIBLY!", "SAFTB!", "FULL SEND!", "FOR THE GUYS!", "HOLD MY BEER!", "BLACKOUT!", "DON'T DO DRUGS, KIDS!", "SLAV SQUAT!", "MIFFLIN BLOCK PARTY!", "GO BADGERS!", "YEE YEE!", "YARDY KNOW WHAT TIME IT IS!", "YA YEET!", "BREWERS > CUBS!", "DON'T BLOW MY SPEAKERS!", "OMG!", "TEQUILA!", "CENTIPEDE!", "B*TCH CUP!", "NAKED LAP!", "JUST GONNA SEND IT!", "SAVE THE ENVIRONMENT!", "DON'T USE #6 PLASTIC!", "DON'T MISS!", "DO A FLIP!", "CANNONBALL!", "BELLYFLOP!", "TSUNAMI!", "SWEET CAROLINE!", "RIP MAC!", "RIP NIPSEY!", "SHOW SOME LOVE!", "DON'T GET ADDICTED!", "ARE WE IN THE MATRIX?", "IT'S PAST MY BEDTIME!", "I SHOULD BE STUDYING RN!", "SHE'S A BAD MAMA JAMA!", "THE BOYS!", "TAKE ONE FOR THE TEAM!", "FBGM!", "IT'S MICKEY MOUSE CLUB HOUSE!", "SHLUMP GANG!", "FLOP GANG!", "DOMINATION!", "MASK OFF!", "DON'T BE A BULLY!", "FRESHMAN!", "NO HIGHSCHOOLERS ALLOWED!", "GAME NIGHT!", "PUMP UP THE JAM!", "IF YOU AIN'T FIRST YOU'RE LAST!"]
    
    //MARK: Properties
    @IBOutlet weak var startButton: UIButton! //Takes you to the pairing screen
    @IBOutlet weak var scoreButton: UIButton! //Takes you to the scores screen
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var hallOfFameButton: UIButton!
    
    @IBOutlet weak var musicButton: UIButton!
    
    @IBOutlet weak var motd: UIButton!
    
    @IBAction func musicButtonPressed(_ sender: Any) {
        if (musicButton.alpha == 1) {
            musicButton.alpha = 0.25
            musicToggle = false
            audioPlayer.setVolume(0.0, fadeDuration: 0)
        } else {
            musicButton.alpha = 1
            audioPlayer.setVolume(1.0, fadeDuration: 0)
            musicToggle = true
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
    
    override func viewDidLayoutSubviews() {
        //motd.centerVertically()
    }
    
    
    @IBAction func motdPressed(_ sender: Any) {
        motd.shake()
        motd.setTitle(motdMessages.randomElement(), for: .normal)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        //Setup the message of the day
        motd.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        motd.titleLabel!.numberOfLines = 3
        motd.setTitle(motdMessages.randomElement(), for: .normal)
        motd.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/4)
        motd.shake()
        
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
    }
    
    //Action to go to pairing screen
    @IBAction func goToPairing(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Pairing", bundle: Bundle.main)
        
        let newViewController = (storyboard.instantiateViewController(withIdentifier: "ViewControllerPairing") as?
            ViewControllerPairing)!
        
        fadeOutAnimationPush(vc: newViewController)
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

//For shake effects on the MOTD. Only needed on the home screen
extension UIButton {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    func lilShake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.08
        animation.values = [-2.0, 1.0, -1.5, 0.5]
        layer.add(animation, forKey: "shake")
    }
}
