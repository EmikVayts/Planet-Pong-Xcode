//
//  ViewController.swift
//
//  Classic gamemode!
//
//  PlanetPongGUI
//
//  Created by Emik Vayts on 4/5/19.
//  Copyright © 2019 Emik Vayts. All rights reserved.
//
//Waddup it's ben

import Foundation
import AudioToolbox
import AVFoundation
import UIKit
import CoreBluetooth
import StatusAlert

class ViewControllerGamemodeWar: ViewControllerGamemode {
    
    //Island cups array
    var islandCups = [Int]()
    var islandUsed = [1, 1, 1, 1]
    
    //Rerack
    var rerackUsed = [1, 1, 1, 1]
    
    //RUN WIHEN VIEW LOADS
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        cupsRemaining = [1, 1, 1, 1]

        //Initial configuration changes depending on the number of players
        if (numPlayers == 3) {
            cupColor = [1, 0, 0, 0, 0, 0, 2, 0, 0, 3];
        } else if (numPlayers == 2){
            cupColor = [1, 0, 0, 0, 0, 0, 2, 0, 0, 0];
        } else if (numPlayers == 4) {
            cupColor = [1, 0, 0, 0, 4, 0, 2, 0, 0, 3];
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createPopup(imageFile: "", titleText: "GAME BEGIN", messageText: "\(playerNames[turn]) START!", duration: 2)
    }

    //UI Buttons press
    @IBAction func undoButtonPress(_ sender: Any) {
        print("undo button pressed")
        //Check if there are any more moves to undo
        if (undoArray.count > 0) {
            print("undo count greather than zero")
            if (undoArray[undoArray.count-1].moveType == "make") {
                print("make undo")
                
                cupsRemaining[turn] -= 1
                
                if (undoArray[undoArray.count-1].prevCupColor != 0) {
                    cupsRemaining[undoArray[undoArray.count-1].prevCupColor-1] += 1
                }
                
                //Change streak
                currentStreak[turn] -= 1
                if (currentStreak[turn]<3) {
                    streak.textColor = UIColor.white
                    fireIcon.image = UIImage(named: "fireIcon")
                }
                
                streak.text = "\(currentStreak[turn])"
                
                //Change the cup to the previous cup color
                cupColor[undoArray[undoArray.count-1].cupChanged] = undoArray[undoArray.count-1].prevCupColor

                print("make undo")
            
                //Checking territories in proximity
                islandCheck()
                
                self.previousShotMade = false
                print("make undo")
                if  (bluetoothEnabled) {
                    self.outgoingData()
                }
                
                self.updateCups()
                self.totalShots[turn]-=1
                self.shotsMade[turn]-=1
                self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
                print("make undo")
            } else if (undoArray[undoArray.count-1].moveType == "miss") {
                
                prevTurn()
                
                //Change streak
                currentStreak[turn] = undoArray[undoArray.count-1].streakLength
                
                self.updateCups()
                self.updatePlayerLabel()
                
                if  (bluetoothEnabled) {
                    self.outgoingData()
                }
                
                self.totalShots[turn]-=1
                self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            } else if (undoArray[undoArray.count-1].moveType == "island") {
                islandUsed[turn] = 1
                islandCheck()
            } else if (undoArray[undoArray.count-1].moveType == "rerack") {
                rerackUsed[turn] = 1
                
                //Switch up to the previous configuration
                for i in 0...9 {
                    cupColor[i] = undoArray[undoArray.count-1].cupConfiguration[i]
                }
                
                if  (bluetoothEnabled) {
                    self.outgoingData()
                }
                
                self.updateCups()
                
                islandCheck()
            }
            //Get rid of the top undo item
            undoArray.remove(at: undoArray.count-1)
            if (undoArray.count == 0) {
                undo.alpha = 0.25
            }
        }
    }
    
    //UNIQUE METHOD
    //Checks to make sure one of the current player's cups are bordering the cup that was hit
    func checkProximity(cupNumber: Int) -> Bool {
        //Reuse island code here
        
        //Island on cup 0
        if ((cupColor[5]==turn+1 || cupColor[8]==turn+1) && cupNumber==9) {
            return true
        } else if ((cupColor[9]==turn+1 || cupColor[8]==turn+1 || cupColor[4]==turn+1 || cupColor[2]==turn+1) && cupNumber==5) { //Island on cup 1
            return true
        } else if ((cupColor[9]==turn+1 || cupColor[5]==turn+1 || cupColor[4]==turn+1 || cupColor[7]==turn+1) && cupNumber==8) { //Island on cup 2
            return true
        } else if ((cupColor[5]==turn+1 || cupColor[4]==turn+1 || cupColor[0]==turn+1 || cupColor[1]==turn+1) && cupNumber==2) { //Island on cup 3
            return true
        } else if ((cupColor[5]==turn+1 || cupColor[2]==turn+1 || cupColor[1]==turn+1 || cupColor[3]==turn+1 || cupColor[7]==turn+1 || cupColor[8]==turn+1) && cupNumber==4) { //Island on cup 4
            return true
        } else if ((cupColor[8]==turn+1 || cupColor[4]==turn+1 || cupColor[3]==turn+1 || cupColor[6]==turn+1) && cupNumber==7) { //Island on cup 5
            return true
        } else if ((cupColor[2]==turn+1 || cupColor[1]==turn+1) && cupNumber==0) { //Island on cup 6
            return true
        } else if ((cupColor[0]==turn+1 || cupColor[2]==turn+1 || cupColor[4]==turn+1 || cupColor[3]==turn+1) && cupNumber==1) { //Island on cup 7
            return true
        } else if ((cupColor[1]==turn+1 || cupColor[4]==turn+1 || cupColor[7]==turn+1 || cupColor[6]==turn+1) && cupNumber==3) { //Island on cup 8
            return true
        } else if ((cupColor[3]==turn+1 || cupColor[7]==turn+1) && cupNumber==6) { //Island on cup 9
            return true
        } else {
            return false
        }
        
    }
    
    //Checks for any isolated cups
    override func islandCheck() {
        
        super.islandCheck()
        
        //Set all cup borders to white
        for i in 0...9 {
            cupButtons[i].layer.borderColor = UIColor.white.cgColor
        }
        
        islandCups.removeAll()
        
        //TODO: Reuse the island sensing code for proximity sensing
        
        //Island on cup 0
        if (cupColor[5]==0 && cupColor[8]==0 && cupColor[9] != 0) {
            islandCups.append(9)
            //button0.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[9]==0 && cupColor[8]==0 && cupColor[4]==0 && cupColor[2]==0 && cupColor[5] != 0) { //Island on cup 1
            islandCups.append(5)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[9]==0 && cupColor[5]==0 && cupColor[4]==0 && cupColor[7]==0 && cupColor[8] != 0) { //Island on cup 2
            islandCups.append(8)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[5]==0 && cupColor[4]==0 && cupColor[0]==0 && cupColor[1]==0 && cupColor[2] != 0) { //Island on cup 3
            islandCups.append(2)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[5]==0 && cupColor[2]==0 && cupColor[1]==0 && cupColor[3]==0 && cupColor[7]==0 && cupColor[8]==0 && cupColor[4] != 0) { //Island on cup 4
            islandCups.append(4)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[8]==0 && cupColor[4]==0 && cupColor[3]==0 && cupColor[6]==0 && cupColor[7] != 0) { //Island on cup 5
            islandCups.append(7)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[2]==0 && cupColor[1]==0 && cupColor[0] != 0) { //Island on cup 6
            islandCups.append(0)
            //button0.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[0]==0 && cupColor[2]==0 && cupColor[4]==0 && cupColor[3]==0 && cupColor[1] != 0) { //Island on cup 7
            islandCups.append(1)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[1]==0 && cupColor[4]==0 && cupColor[7]==0 && cupColor[6]==0 && cupColor[3] != 0) { //Island on cup 8
            islandCups.append(3)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[3]==0 && cupColor[7]==0 && cupColor[6] != 0) { //Island on cup 9
            islandCups.append(6)
            //button0.layer.borderColor = UIColor.yellow.cgColor;
        }
        
        if (islandCups.count==0) {
            island.alpha=0
        }
        
        if (islandUsed[turn]==0 || cupsRemaining[turn]<3) {
            island.alpha=0
        }
    }
    
    //What happens when a cup is hit
    override func cupHit(cupNumber: Int) {
        
        super.cupHit(cupNumber: cupNumber)
        
        var shotMade = false
        
        //War mode response to cup getting hit
        print("Cup hit!")
        //TODO --> Make it check for proximity
        //Make sure you didn't hit your own color
        if (cupColor[cupNumber] != turn+1) {
            //Checks if the shot was in proximity of the players cup and a valid target
            if (checkProximity(cupNumber: cupNumber)) {
                
                cupsRemaining[turn] += 1
                
                if (cupColor[cupNumber] != 0) {
                    cupsRemaining[cupColor[cupNumber]-1] -= 1
                    
                    if (cupsRemaining[cupColor[cupNumber]-1] == 1) {
                        createPopup(imageFile: "", titleText: "\(playerNames[cupColor[cupNumber]-1]) HAS ONE TERRITORY LEFT", messageText: "", duration: 2)
                    } else if (cupsRemaining[cupColor[cupNumber]-1] == 0) {
                        createPopup(imageFile: "", titleText: "\(playerNames[turn]) ELIMINATED \(playerNames[cupColor[cupNumber]-1])", messageText: "", duration: 2)
                    }
                    
                }
                
                //Check if we made another players cup or an empty space
                if (cupColor[cupNumber] == 0) {
                    createPopup(imageFile: "", titleText: "YOU CAPTURED AN EMPTY TERRITORY", messageText: "", duration: 2)
                } else {
                    createPopup(imageFile: "", titleText: "YOU CAPTURED \(playerNames[cupColor[cupNumber]-1])'S TERRITORY", messageText: "", duration: 2)
                }
                
                shotMade = true
                
                undoArray.append(UndoTurn(moveType: "make", cupChanged: cupNumber, prevCupColor: cupColor[cupNumber]))
                
                cupColor[cupNumber] = turn+1
                
                updateCups()
                
                //Increase streak
                currentStreak[turn] += 1
                
                //Check for final village remaining
                if (cupsRemaining[turn]==1) {
                    createPopup(imageFile: "", titleText: "LAST CUP", messageText: "", duration: 2)
                }
                
                //Check for a player being eliminated
                if (cupsRemaining[turn]==0) {
                    createPopup(imageFile: "", titleText: "PLAYER \(turn+1) WINS", messageText: "", duration: 2)
                }
                
                self.previousShotMade = false
                
                islandCheck()
                
                self.shotsMade[turn]+=1
                totalShots[turn]+=1
                
                //Update streak text
                if (currentStreak[turn]>=3) {
                    if (currentStreak[turn]==3) {
                        createPopup(imageFile: "", titleText: "ON FIRE", messageText: "", duration: 2)
                    }
                    streak.textColor = UIColor.orange
                    fireIcon.image = UIImage(named: "fireIconLit")
                }
                
                streak.text = "\(currentStreak[turn])"
                
                //Add the make move to the undo array
                undo.alpha = 1
                
                //Vibrate the phone as positive reinforcement
                AudioServicesPlaySystemSound(1013)
                self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
                
            }
        }
        
        if (!shotMade) {
            ballShot()
        }
    }
    
    //What happens when a ball is shot
    override func ballShot() {
        
        super.ballShot()
        
        //Check if the ball was missed
        if (self.previousShotMade==false) {
            
            //Add the miss move to the undo array
            undo.alpha = 1
            undoArray.append(UndoTurn(moveType: "miss", streakLength: currentStreak[turn]))
            
            //Streak is over
            currentStreak[turn] = 0
            
            nextTurn()
            
            updatePlayerLabel()
            
            AudioServicesPlaySystemSound(1103)
            
        } else {
            //Just a continuation of the shot being made
            self.previousShotMade=false
        }
        
        self.updateCups()
        self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
    }
    
    override func updatePlayerLabel() {
        
        super.updatePlayerLabel()
        
        //Streak check
        streak.text = "\(currentStreak[turn])"
        if (currentStreak[turn] >= 3) {
            streak.textColor = UIColor.orange
            fireIcon.image = UIImage(named: "fireIconLit")
        } else {
            streak.textColor = UIColor.white
            fireIcon.image = UIImage(named: "fireIcon")
        }
        
        //Island check
        islandCheck()
    }
    
    //Set the cup and UI button stylings
    override func styleButton() {
        
        super.styleButton()
        
        //TODO: Change these guys to something else... *ATTAC OR PROTEC
        rerack.layer.borderColor = UIColor.white.cgColor;
        rerack.layer.borderWidth = 3;
        rerack.layer.cornerRadius = 3
        rerack.alpha = 0
        
        island.layer.borderColor = UIColor.white.cgColor;
        island.layer.borderWidth = 3;
        island.layer.cornerRadius = 3;
        island.alpha = 0
    }
}
