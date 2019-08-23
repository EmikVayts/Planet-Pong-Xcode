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

class ViewControllerGamemodeClassic: ViewControllerGamemode {

    //Island cups array
    var islandCups = [Int]()
    var islandUsed = [1, 1, 1, 1]
    
    //Rerack
    var rerackUsed = [1, 1, 1, 1]

    //RUN WIHEN VIEW LOADS
    override func viewDidLoad() {

        cupsRemaining = [10, 10, 10, 10]
        
        //Array of button objects
        //cupButtons = [button6, button7, button3, button8, button4, button1, button9, button5, button2, button0];
        
        //cupButtons = [button0, button1, button2, button3, button4, button5, button6, button7, button8, button9];
        
        //CUP ARRAYS
        //Diagram
        //
        //
        //
        //
        //
        //
        //
        //cupColor = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]; //Set all cup colors to red for ARCADE mode
        
        //cupColor = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; //Set all cup colors to red for SNIPER mode
        //let randCup = Int.random(in: 0 ... 9)
        //cupColor[randCup] = 1
        
        //cupColor = [3, 2, 2, 2, 1, 2, 3, 2, 2, 3]; //Set the colors for DARTS mode
        
        cupColorMultiple = [[1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4]];
        
        boardType = "multiple"
        
        super.viewDidLoad()
        //styleButton();
        
        //view.setNeedsDisplay();
        //cup0Button.backgroundColor = UIColor.green;
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialized based on if bluetooth is enabled or not
        /*if (bluetoothEnabled) {
            //Create and start the peripheral manager
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            
            //-Notification for updating the text view with incoming text
            updateIncomingData()
        } else {
            //Initialize labels
            let attrString = NSAttributedString(string: "Player 1 Turn #1", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: UIColor.red, NSAttributedString.Key.strokeWidth: -7.0])
            self.playerTurn.attributedText = attrString
        }*/
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
                
                //Change streak
                currentStreak[turn] -= 1
                if (currentStreak[turn]<3) {
                    streak.textColor = UIColor.white
                    fireIcon.image = UIImage(named: "fireIcon")
                }
                
                streak.text = "\(currentStreak[turn])"
                
                if (turn==0) {
                    cupColorMultiple[undoArray[undoArray.count-1].cupChanged][turn] = 1
                } else if (turn==1) {
                    cupColorMultiple[undoArray[undoArray.count-1].cupChanged][turn] = 2
                } else if (turn==2) {
                    cupColorMultiple[undoArray[undoArray.count-1].cupChanged][turn] = 3
                } else if (turn==3) {
                    cupColorMultiple[undoArray[undoArray.count-1].cupChanged][turn] = 4
                }
                print("make undo")
                cupsRemaining[turn] += 1
                
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
                    cupColorMultiple[i][turn] = undoArray[undoArray.count-1].cupConfiguration[i]
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
    
    @IBAction func rerackButtonPress(_ sender: Any) {
        if (rerack.alpha==1) {
            rerackUsed[turn] = 0
            rerack.alpha=0
            
            createPopup(imageFile: "", titleText: "RERACK", messageText: "", duration: 2)
            
            let rackColor = turn+1
            
            var currentCupConfig = [Int]()
            
            //Save the current cup configuration to the undo stack
            for i in 0...9 {
                currentCupConfig.append(cupColorMultiple[i][turn])
            }
            
            undoArray.append(UndoTurn(moveType: "rerack", cupConfiguration: currentCupConfig))
            
            //Clear the cups off the board and then add the new rack
            for i in 0...9 {
                cupColorMultiple[i][turn] = 0
            }
            
            //6 rack
            if (cupsRemaining[turn] == 6) {
                cupColorMultiple[5][turn] = rackColor
                cupColorMultiple[2][turn] = rackColor
                cupColorMultiple[4][turn] = rackColor
                cupColorMultiple[0][turn] = rackColor
                cupColorMultiple[1][turn] = rackColor
                cupColorMultiple[3][turn] = rackColor
            }
            
            //4 rack
            if (cupsRemaining[turn] == 4) {
                cupColorMultiple[5][turn] = rackColor
                cupColorMultiple[2][turn] = rackColor
                cupColorMultiple[4][turn] = rackColor
                cupColorMultiple[1][turn] = rackColor
            }
            
            //3 rack
            if (cupsRemaining[turn] == 3) {
                cupColorMultiple[4][turn] = rackColor
                cupColorMultiple[1][turn] = rackColor
                cupColorMultiple[3][turn] = rackColor
            }
            
            //2 rack
            if (cupsRemaining[turn] == 2) {
                cupColorMultiple[4][turn] = rackColor
                cupColorMultiple[9][turn] = rackColor
            }
            
            //1 rack
            if (cupsRemaining[turn] == 1) {
                cupColorMultiple[4][turn] = rackColor
            }
            
            self.updateCups()
            
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
    }
    
    @IBAction func islandButtonPress(_ sender: Any) {
        //Check if we can use Island
        if (island.alpha==1) {
            for i in 0...islandCups.count-1 {
                cupButtons[islandCups[i]].layer.borderColor = UIColor.yellow.cgColor
                islandUsed[turn] = 0
                undoArray.append(UndoTurn(moveType: "island"))
                island.alpha=0
            }
        }
    }
    
    //Checks for any isolated cups
    override func islandCheck() {
        
        super.islandCheck()
        
        //Check for rerack
        if (rerackUsed[turn] == 1) {
            if ((cupsRemaining[turn] == 6 || cupsRemaining[turn] == 4 || cupsRemaining[turn] == 3 || cupsRemaining[turn] == 2 || cupsRemaining[turn] == 1) && currentStreak[turn]==0) {
                rerack.alpha=1
            } else {
                rerack.alpha=0.25
            }
        } else {
            rerack.alpha = 0
        }
        
        //Set all cup borders to white
        for i in 0...9 {
            cupButtons[i].layer.borderColor = UIColor.white.cgColor
        }
        
        islandCups.removeAll()
        
        //Island on cup 0
        if (cupColorMultiple[5][turn]==0 && cupColorMultiple[8][turn]==0 && cupColorMultiple[9][turn] != 0) {
            island.alpha=1
            islandCups.append(9)
            //button0.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColorMultiple[9][turn]==0 && cupColorMultiple[8][turn]==0 && cupColorMultiple[4][turn]==0 && cupColorMultiple[2][turn]==0 && cupColorMultiple[5][turn] != 0) { //Island on cup 1
            island.alpha=1
            islandCups.append(5)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColorMultiple[9][turn]==0 && cupColorMultiple[5][turn]==0 && cupColorMultiple[4][turn]==0 && cupColorMultiple[7][turn]==0 && cupColorMultiple[8][turn] != 0) { //Island on cup 2
            island.alpha=1
            islandCups.append(8)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColorMultiple[5][turn]==0 && cupColorMultiple[4][turn]==0 && cupColorMultiple[0][turn]==0 && cupColorMultiple[1][turn]==0 && cupColorMultiple[2][turn] != 0) { //Island on cup 3
            island.alpha=1
            islandCups.append(2)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColorMultiple[5][turn]==0 && cupColorMultiple[2][turn]==0 && cupColorMultiple[1][turn]==0 && cupColorMultiple[3][turn]==0 && cupColorMultiple[7][turn]==0 && cupColorMultiple[8][turn]==0 && cupColorMultiple[4][turn] != 0) { //Island on cup 4
            island.alpha=1
            islandCups.append(4)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColorMultiple[8][turn]==0 && cupColorMultiple[4][turn]==0 && cupColorMultiple[3][turn]==0 && cupColorMultiple[6][turn]==0 && cupColorMultiple[7][turn] != 0) { //Island on cup 5
            island.alpha=1
            islandCups.append(7)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColorMultiple[2][turn]==0 && cupColorMultiple[1][turn]==0 && cupColorMultiple[0][turn] != 0) { //Island on cup 6
            island.alpha=1
            islandCups.append(0)
            //button0.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColorMultiple[0][turn]==0 && cupColorMultiple[2][turn]==0 && cupColorMultiple[4][turn]==0 && cupColorMultiple[3][turn]==0 && cupColorMultiple[1][turn] != 0) { //Island on cup 7
            island.alpha=1
            islandCups.append(1)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColorMultiple[1][turn]==0 && cupColorMultiple[4][turn]==0 && cupColorMultiple[7][turn]==0 && cupColorMultiple[6][turn]==0 && cupColorMultiple[3][turn] != 0) { //Island on cup 8
            island.alpha=1
            islandCups.append(3)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColorMultiple[3][turn]==0 && cupColorMultiple[7][turn]==0 && cupColorMultiple[6][turn] != 0) { //Island on cup 9
            island.alpha=1
            islandCups.append(6)
            //button0.layer.borderColor = UIColor.yellow.cgColor;
        }
        
        if (islandCups.count==0) {
            island.alpha=0.25
        }
        
        if (islandUsed[turn]==0 || cupsRemaining[turn]<3) {
            island.alpha=0
        }
    }
    
    //Checks if there is an incoming string from the ESP32 and then prints it out on the console if there is one
    /*func updateIncomingData () {
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil) {
            notification in
            if (self.ratchetFix == false) {
                self.ratchetFix = true
                //Set initial cups
                self.outgoingData()
                
                //Initialize labels
                let attrString = NSAttributedString(string: "Player 1 Turn #1", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: UIColor.red, NSAttributedString.Key.strokeWidth: -7.0])
                self.playerTurn.attributedText = attrString
                
                self.updateCups()
            } else {
                let incomingString = (characteristicASCIIValue as String)
                print(incomingString)
                
                //PARSE THE INCOMING VALUE
                //IF CUP HIT
                if (incomingString[incomingString.index(incomingString.startIndex, offsetBy: 0)] == "0") {
                    let cupNum = Int(String(incomingString[incomingString.index(incomingString.startIndex, offsetBy: 1)]))

                    self.cupHit(cupNumber: cupNum ?? 0)
                    
                    self.previousShotMade = true
                    
                    //Update the cup color accordingly ARCADE MODE
                    /*var currentColor = self.cupColor[cupNum ?? 0]
                    currentColor+=1
                    if (currentColor == 5) {
                        currentColor = 1
                    }
                    
                    self.cupColor[cupNum ?? 0] = currentColor
                    
                    //self.cupColor[cupNum ?? 0] = Int.random(in: 1 ... 4)
                    self.updateCup(cup: cupNum ?? 0)*/
                    
                    //UPDATE A RANDOM CUP SNIPER MODE
                    /*self.cupColor = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; //Set all cup colors to red for SNIPER mode
                    let randCup = Int.random(in: 0 ... 9)
                    self.cupColor[randCup] = 1
                    self.updateCups()*/
                    //Make sure that the random value isn't the same two shots in a row
                    
                    //DARTS MODE
                    /*if (cupNum==0 || cupNum == 6 || cupNum == 9) {
                        self.scorePoints += 1
                        self.time.text = ("Points: \(self.scorePoints)")
                    } else if (cupNum == 4) {
                        self.scorePoints += 5
                        self.time.text = ("Points: \(self.scorePoints)")
                    } else {
                        self.scorePoints += 3
                        self.time.text = ("Points: \(self.scorePoints)")
                    }
                    
                    if (self.scorePoints >= 21) {
                        self.scorePoints = 0
                    }*/
                    
                    self.outgoingData()
                    
                    //Respond to the ESP32
                    /*let inputText = ("0\(self.cupColor[0])\(self.cupColor[1])\(self.cupColor[2])\(self.cupColor[3])\(self.cupColor[4])\(self.cupColor[5])\(self.cupColor[6])\(self.cupColor[7])\(self.cupColor[8])\(self.cupColor[9])")
                    self.writeValue(data: inputText)*/
                }
                
                //IF TOTAL BALLS SHOT INCREMENTED
                if (incomingString[incomingString.index(incomingString.startIndex, offsetBy: 0)] == "1") {
                    self.ballShot()
                    self.outgoingData()
                }
            }
        }
    }*/
    
    //What happens when a cup is hit
    override func cupHit(cupNumber: Int) {
        
        super.cupHit(cupNumber: cupNumber)
        
        var shotMade = false
        
        //Make sure you didn't hit an empty cup
        if (cupColorMultiple[cupNumber][self.turn] != 0) {
            //Increase streak
            currentStreak[turn] += 1
            
            shotMade = true
            self.totalShots[turn]+=1
            
            //Classic mode response to cup getting hit
            print("Cup hit!")
            self.cupColorMultiple[cupNumber][self.turn] = 0
            self.updateCup(cup: cupNumber)
            
            cupsRemaining[turn] -= 1
            
            //Check for bitch cup
            if (cupsRemaining[turn]==9 && self.cupColorMultiple[4][self.turn]==0) {
                createPopup(imageFile: "", titleText: "B*TCH CUP", messageText: "Put yo pants down!", duration: 2)
            }
            
            //Check for ring of death
            if (cupsRemaining[turn]==6 && cupColorMultiple[4][turn]==0 && cupColorMultiple[0][turn]==0 && cupColorMultiple[6][turn]==0 && cupColorMultiple[9][turn]==0) {
                createPopup(imageFile: "RingOfDeathImage", titleText: "PLAYER \(turn+1) WINS", messageText: "", duration: 2)
            }
            
            //Check for final cup remaining
            if (cupsRemaining[turn]==1) {
                createPopup(imageFile: "", titleText: "LAST CUP", messageText: "", duration: 2)
            }
            
            //Check for final cup remaining
            if (cupsRemaining[turn]==0) {
                createPopup(imageFile: "", titleText: "PLAYER \(turn+1) WINS", messageText: "", duration: 2)
            }
            
            self.previousShotMade = false
            
            //Check if an island cup was hit
            if (cupButtons[cupNumber].layer.borderColor == UIColor.yellow.cgColor) {
                
                createPopup(imageFile: "", titleText: "ISLAND", messageText: "2 cups down!", duration: 2)
                
                //Remove an additional cup
                self.shotsMade[turn]+=1
                self.totalShots[turn]+=1
                for i in stride(from: 9, through: 0, by: -1) {
                    if (i != cupNumber) {
                        if (self.cupColorMultiple[i][self.turn] != 0) {
                            self.cupColorMultiple[i][self.turn] = 0
                            self.updateCup(cup: i)
                            cupsRemaining[turn] -= 1
                            currentStreak[turn] += 1
                            undoArray.append(UndoTurn(moveType: "make", cupChanged: i))
                            break
                        }
                    }
                }
            }
            
            undoArray.append(UndoTurn(moveType: "make", cupChanged: cupNumber))
            
            islandCheck()
            
            self.shotsMade[turn]+=1
            
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
        
        if (!shotMade) {
            ballShot()
        }
    }
    
    //What happens when a ball is shot
    override func ballShot() {
        
        super.ballShot()
        
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
        
        rerack.layer.borderColor = UIColor.white.cgColor;
        rerack.layer.borderWidth = 3;
        rerack.layer.cornerRadius = 3
        rerack.alpha = 0.25
        
        island.layer.borderColor = UIColor.white.cgColor;
        island.layer.borderWidth = 3;
        island.layer.cornerRadius = 3;
        island.alpha = 0.25
    }
}
