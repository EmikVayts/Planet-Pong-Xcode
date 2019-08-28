//
//  ViewControllerSpinner.swift
//  Planet Pong
//
//  Created by Mac on 8/18/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import StatusAlert

class ViewControllerSpinner: SpaceVibe {
    
    var numPlayers = 3 //Spinner can work for 2-4 players (If only 1 player bypass the spinner)
    var playerPerTeam = 1
    var playerNames = ["Tony", "Yolanda", "Bethany", "Charles"]
    var spinTime = 0.5
    var destAngle = 17.0
    var pass = 0
    var passTotal = 14
    var animationType = UIView.AnimationOptions.curveLinear
    var gameSelected = "war"
    
    var spun = false
    @IBOutlet weak var spinner: UIImageView!
    @IBOutlet weak var threeSpinner: UIButton!
    
    @IBAction func spinTheWheel(_ sender: Any) {
        if (!spun) {
            
            self.spinner.transform = CGAffineTransform(rotationAngle: CGFloat((-30.0 * .pi) / 180.0))
            
            animationType = UIView.AnimationOptions.curveLinear
            
            pass = 0
            
            var passVals = [Int]()
            if (numPlayers == 2 || playerPerTeam==2) {
                passVals = [11,13]
                destAngle = 90.0
            } else if (numPlayers == 3) {
                passVals = [11,13,15]
                destAngle = 30.0
            } else if (numPlayers == 4) {
                passVals = [9,11,13,15]
                destAngle = 0.0
            }
            passTotal = passVals.randomElement()!
            
            spinTime = 0.05
            
            spun = true

            rotationCycle()
        }
    }
    
    func playSFX (sound: String) {
        
        if (pass != 0) {
            sfxPlayer.stop()
        }
        
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: "mp3")!))
            //sfxPlayer.numberOfLoops = -1
            sfxPlayer.prepareToPlay()
        } catch {
            print(error)
        }
        
        //Actually play the audio
        sfxPlayer.play()
    }
    
    func rotationCycle() {
        
        //Play the spinning tick sound effect every other pass of the rotation cycle
        if (pass%2 == 0) {
            if (pass == passTotal+1) {
                //THE FINAL PASS!
                
                playSFX(sound: "spinner2")
                
                //Delay it for a second before fading to the next screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    
                    var newViewController: ViewControllerGamemode?
                    
                    //SETTINGS UNIQUE TO EACH GAMEMODE
                    
                    if (self.gameSelected == "war") {
                        let storyboard = UIStoryboard(name: "GamemodeClassic", bundle: nil)
                        
                        newViewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerGamemodeClassic") as! ViewControllerGamemodeClassic

                    }
                    
                    //SETTINGS UNIVERSAL FOR ALL GAMEMODES
                    
                    newViewController!.bluetoothEnabled = false
                    
                    newViewController!.numPlayers = 4//self.numPlayers
                    
                    newViewController!.playerPerTeam = self.playerPerTeam
                    
                    newViewController!.playerNames = self.playerNames
                    
                    if (self.playerPerTeam == 2) {
                        if (self.passTotal == 13) {
                            newViewController?.turn = 0
                        } else if (self.passTotal == 11) {
                            newViewController?.turn = 2
                        }
                    } else if (self.numPlayers==2) {
                        if (self.passTotal == 13) {
                            newViewController?.turn = 0
                        } else if (self.passTotal == 11) {
                            newViewController?.turn = 1
                        }
                    } else if (self.numPlayers==3) {
                        if (self.passTotal == 11) {
                            newViewController?.turn = 1
                        } else if (self.passTotal == 13) {
                            newViewController?.turn = 2
                        } else if (self.passTotal == 15) {
                            newViewController?.turn = 0
                        }
                    } else if (self.numPlayers==4) {
                        if (self.passTotal == 9) {
                            newViewController?.turn = 0
                        } else if (self.passTotal == 11) {
                            newViewController?.turn = 1
                        } else if (self.passTotal == 13) {
                            newViewController?.turn = 2
                        } else if (self.passTotal == 15) {
                            newViewController?.turn = 3
                        }
                    }
                    
                    newViewController?.firstPlayer = newViewController!.turn
                    
                    self.fadeOutAnimationPush(vc: newViewController!)
                }

                
                //Announce who the first player to start is
                /*let statusAlert = StatusAlert()
                statusAlert.appearance.tintColor = UIColor.white
                statusAlert.appearance.titleFont = UIFont(name: "Myriad Pro Semibold", size: 28) ?? UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.regular)
                statusAlert.appearance.messageFont = UIFont(name: "Myriad Pro Semibold", size: 20) ?? UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
                //statusAlert.backgroundColor = UIColor.black
                //statusAlert.image = UIImage(named: imageFile)
                statusAlert.title = "PLAYER # GETS TO GO FIRST!"
                statusAlert.alertShowingDuration = 2
                statusAlert.canBePickedOrDismissed = true
                
                // Presenting created instance
                statusAlert.showInKeyWindow()*/
                
            } else {
                playSFX(sound: "spinner1")
            }
        }
        
        if (pass < passTotal+1) {
        
            UIView.animate(withDuration: spinTime, delay: 0.0, options: self.animationType, animations: {
                self.spinner.transform = CGAffineTransform(rotationAngle: CGFloat((self.destAngle * .pi) / 180.0))
            }, completion: {
                (finished: Bool) in
                self.pass+=1
                
                self.spinTime += 0.01 * Double(self.pass)
                
                if (self.numPlayers == 2) {
                    self.destAngle += 90.0
                } else if (self.numPlayers == 3) {
                    self.destAngle += 60
                } else if (self.numPlayers == 4) {
                    self.destAngle += 45
                }
                
                if ((self.destAngle) >= 180.0) {
                    self.destAngle = -180.0+((self.destAngle) .truncatingRemainder(dividingBy: 180.0))
                }
                
                if (self.pass <= self.passTotal) {
                    if (self.pass == self.passTotal) {
                        self.spinTime *= 2
                        self.animationType = UIView.AnimationOptions.curveEaseOut
                    }
                }
                
                self.rotationCycle()
                
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (numPlayers == 2 || playerPerTeam==2) {
            threeSpinner.setImage(UIImage(named: "TwoSpinner"), for: .normal)
        } else if (numPlayers == 3) {
            threeSpinner.setImage(UIImage(named: "ThreeSpinner"), for: .normal)
            self.spinner.transform = CGAffineTransform(rotationAngle: CGFloat((-30.0 * .pi) / 180.0))
        } else if (numPlayers == 4) {
            threeSpinner.setImage(UIImage(named: "FourSpinner"), for: .normal)
            self.spinner.transform = CGAffineTransform(rotationAngle: CGFloat((-45.0 * .pi) / 180.0))
        }
    }
}
