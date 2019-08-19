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

class ViewControllerGamemodeClassic: SpaceVibe, CBPeripheralManagerDelegate {
    
    //The object holding the information for one move
    class UndoTurn {
        var moveType = ""
        var cupChanged = -1
        var cupConfiguration = [Int]()
        var streakLength = 0
        
        init(moveType: String, cupConfiguration: [Int]) {
            self.moveType = moveType
            self.cupConfiguration = cupConfiguration
        }
        
        init(moveType: String, cupChanged: Int) {
            self.moveType = moveType
            self.cupChanged = cupChanged
        }
        
        init(moveType: String) {
            self.moveType = moveType
        }
        
        init(moveType: String, streakLength: Int) {
            self.moveType = moveType
            self.streakLength = streakLength
        }
    }
    
    /*func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            //
        } else {
            print("NOaked")
            disconnectDevice()
        }
    }*/

    //Create links to all of the items displayed on the screen
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button0: UIButton!
    
    @IBOutlet weak var playerTurn: UILabel!
    
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var score: UITextField!
    @IBOutlet weak var streak: UITextField!
    
    @IBOutlet weak var fireIcon: UIImageView!
    
    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var miss: UIButton!
    
    @IBOutlet weak var island: UIButton!
    @IBOutlet weak var rerack: UIButton!
    
    //Bluetooth Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    var centralManager : CBCentralManager!
    
    var central: CBCentralManager?
    
    var bluetoothEnabled = true
    
    lazy var cupButtons = [UIButton]();
    //Single player gamemode
    var cupColor = [[Int]]();
    
    var cupsRemaining = [10, 10, 10, 10]
    
    var turn = 0 //The turn of the player currently going
    var round = 1 //The current round
    var previousShotMade = false
    
    //Ratchet Fix - prevents the BLE signal to carry over from the previous game
    var ratchetFix = false
    
    //Observer for incoming BLE strings
    var observer: NSObjectProtocol!
    
    //Timer
    var timer = Timer()
    var timeElapsed = [0, 0, 0, 0] //In seconds
    
    //Score
    var totalShots = [0, 0, 0, 0]
    var shotsMade = [0, 0, 0, 0]
    var scorePoints = 0
    
    //Undo array
    var undoArray = [UndoTurn]()
    
    //Island cups array
    var islandCups = [Int]()
    var islandUsed = [1, 1, 1, 1]
    
    //Rerack
    var rerackUsed = [1, 1, 1, 1]
    
    //Streak
    var currentStreak = [0, 0, 0, 0]
    
    //RUN WIHEN VIEW LOADS
    override func viewDidLoad() {

        //Ratchet Fix
        ratchetFix = false
        
        //Timer
        timeElapsed = [0, 0, 0, 0]
        
        //Score
        totalShots = [0, 0, 0, 0]
        shotsMade = [0, 0, 0, 0]
        scorePoints = 0
        
        //Array of button objects
        cupButtons = [button6, button7, button3, button8, button4, button1, button9, button5, button2, button0];
        
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
        
        cupColor = [[1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4]]; //Sets the colors for classic MULTIPLAYER mode with a 2D array
        
        /*cupColor1 = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]; //Set the colors for CLASSIC MULTIPLAYER mode
        cupColor2 = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2];
        cupColor3 = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3];
        cupColor4 = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4];*/
        
        //Set the turn of the player currently going (From 0-3)
        turn = 0
        round = 1
        
        //Set if the previous shot was a make or miss
        previousShotMade=false
        
        //Start timer
        scheduledTimerWithTimeInterval()
        
        //Update score
        
        super.viewDidLoad()
        styleButton();
        
        view.setNeedsDisplay();
        //cup0Button.backgroundColor = UIColor.green;
        // Do any additional setup after loading the view, typically from a nib.
        
        //Initialized based on if bluetooth is enabled or not
        if (bluetoothEnabled) {
            //Create and start the peripheral manager
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            
            //-Notification for updating the text view with incoming text
            updateIncomingData()
        } else {
            //Initialize labels
            let attrString = NSAttributedString(string: "Player 1 Turn #1", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: UIColor.red, NSAttributedString.Key.strokeWidth: -7.0])
            self.playerTurn.attributedText = attrString
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        createPopup(imageFile: "", titleText: "GAME BEGIN", messageText: "PLAYER 1 START!", duration: 2)
        ratchetFix = false
        styleButton()
        if (!bluetoothEnabled) {
            self.updateCups()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if (bluetoothEnabled) {
            self.peripheralManager?.stopAdvertising()
            NotificationCenter.default.removeObserver(observer)
        }
        //self.peripheralManager = nil
        super.viewDidDisappear(animated)
        print("Disconnecting, so now removing observer and timer from gamemode classic")
        //NotificationCenter.default.removeObserver(self)
        timer.invalidate()
    }

    //Create a new message box
    func createPopup(imageFile: String, titleText: String, messageText: String, duration: Double) {
        // Creating StatusAlert instance
        let statusAlert = StatusAlert()
        statusAlert.appearance.tintColor = UIColor.white
        statusAlert.appearance.titleFont = UIFont(name: "Myriad Pro Semibold", size: 28) ?? UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.regular)
        statusAlert.appearance.messageFont = UIFont(name: "Myriad Pro Semibold", size: 20) ?? UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        //statusAlert.backgroundColor = UIColor.black
        statusAlert.image = UIImage(named: imageFile)
        statusAlert.title = titleText
        statusAlert.message = messageText
        statusAlert.alertShowingDuration = duration
        statusAlert.canBePickedOrDismissed = true
        
        // Presenting created instance
        statusAlert.showInKeyWindow()
    }
    
    //UI Cups Press
    //cupButtons = [button6, button7, button3, button8, button4, button1, button9, button5, button2, button0];
    @IBAction func button0Press(_ sender: Any) {
        if (cupColor[9][turn] != 0) {
            //button0.layer.borderColor = UIColor.yellow.cgColor;
            self.cupHit(cupNumber: 9)
            self.totalShots[turn]+=1
            self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
    }
    
    @IBAction func button1Press(_ sender: Any) {
        if (cupColor[5][turn] != 0) {
            //button1.layer.borderColor = UIColor.yellow.cgColor;
            self.cupHit(cupNumber: 5)
            self.totalShots[turn]+=1
            self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
    }
    
    @IBAction func button2Press(_ sender: Any) {
        if (cupColor[8][turn] != 0) {
            //button2.layer.borderColor = UIColor.yellow.cgColor;
            self.cupHit(cupNumber: 8)
            self.totalShots[turn]+=1
            self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
    }
    
    @IBAction func button3Press(_ sender: Any) {
        if (cupColor[2][turn] != 0) {
            //button3.layer.borderColor = UIColor.yellow.cgColor;
            self.cupHit(cupNumber: 2)
            self.totalShots[turn]+=1
            self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
    }
    
    @IBAction func button4Press(_ sender: Any) {
        if (cupColor[4][turn] != 0) {
            //button4.layer.borderColor = UIColor.yellow.cgColor;
            self.cupHit(cupNumber: 4)
            self.totalShots[turn]+=1
            self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
    }
    
    @IBAction func button5Press(_ sender: Any) {
        if (cupColor[7][turn] != 0) {
            //button5.layer.borderColor = UIColor.yellow.cgColor;
            self.cupHit(cupNumber: 7)
            self.totalShots[turn]+=1
            self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
    }
    
    @IBAction func button6Press(_ sender: Any) {
        if (cupColor[0][turn] != 0) {
            //button6.layer.borderColor = UIColor.yellow.cgColor;
            self.cupHit(cupNumber: 0)
            self.totalShots[turn]+=1
            self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
    }
    
    @IBAction func button7Press(_ sender: Any) {
        if (cupColor[1][turn] != 0) {
            //button7.layer.borderColor = UIColor.yellow.cgColor;
            self.cupHit(cupNumber: 1)
            self.totalShots[turn]+=1
            self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
    }
    
    @IBAction func button8Press(_ sender: Any) {
        if (cupColor[3][turn] != 0) {
            //button8.layer.borderColor = UIColor.yellow.cgColor;
            self.cupHit(cupNumber: 3)
            self.totalShots[turn]+=1
            self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
    }
    
    @IBAction func button9Press(_ sender: Any) {
        if (cupColor[6][turn] != 0) {
            //button9.layer.borderColor = UIColor.yellow.cgColor;
            self.cupHit(cupNumber: 6)
            self.totalShots[turn]+=1
            self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
            if (bluetoothEnabled) {
                self.outgoingData()
            }
        }
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
                    cupColor[undoArray[undoArray.count-1].cupChanged][turn] = 1
                } else if (turn==1) {
                    cupColor[undoArray[undoArray.count-1].cupChanged][turn] = 2
                } else if (turn==2) {
                    cupColor[undoArray[undoArray.count-1].cupChanged][turn] = 3
                } else if (turn==3) {
                    cupColor[undoArray[undoArray.count-1].cupChanged][turn] = 4
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
                
                //Undo the turn change
                if (self.turn>0) {
                    self.turn-=1
                } else {
                    self.turn=3
                    self.round-=1
                }
                
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
                    cupColor[i][turn] = undoArray[undoArray.count-1].cupConfiguration[i]
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
    
    @IBAction func missButtonPress(_ sender: Any) {
        self.previousShotMade = false
        self.ballShot()
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    //cupButtons = [button6, button7, button3, button8, button4, button1, button9, button5, button2, button0]
    
    @IBAction func rerackButtonPress(_ sender: Any) {
        if (rerack.alpha==1) {
            rerackUsed[turn] = 0
            rerack.alpha=0
            
            createPopup(imageFile: "", titleText: "RERACK", messageText: "", duration: 2)
            
            let rackColor = turn+1
            
            var currentCupConfig = [Int]()
            
            //Save the current cup configuration to the undo stack
            for i in 0...9 {
                currentCupConfig.append(cupColor[i][turn])
            }
            
            undoArray.append(UndoTurn(moveType: "rerack", cupConfiguration: currentCupConfig))
            
            //Clear the cups off the board and then add the new rack
            for i in 0...9 {
                cupColor[i][turn] = 0
            }
            
            //6 rack
            if (cupsRemaining[turn] == 6) {
                cupColor[5][turn] = rackColor
                cupColor[2][turn] = rackColor
                cupColor[4][turn] = rackColor
                cupColor[0][turn] = rackColor
                cupColor[1][turn] = rackColor
                cupColor[3][turn] = rackColor
            }
            
            //4 rack
            if (cupsRemaining[turn] == 4) {
                cupColor[5][turn] = rackColor
                cupColor[2][turn] = rackColor
                cupColor[4][turn] = rackColor
                cupColor[1][turn] = rackColor
            }
            
            //3 rack
            if (cupsRemaining[turn] == 3) {
                cupColor[4][turn] = rackColor
                cupColor[1][turn] = rackColor
                cupColor[3][turn] = rackColor
            }
            
            //2 rack
            if (cupsRemaining[turn] == 2) {
                cupColor[4][turn] = rackColor
                cupColor[9][turn] = rackColor
            }
            
            //1 rack
            if (cupsRemaining[turn] == 1) {
                cupColor[4][turn] = rackColor
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
    func islandCheck() {
        
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
        if (cupColor[5][turn]==0 && cupColor[8][turn]==0 && cupColor[9][turn] != 0) {
            island.alpha=1
            islandCups.append(9)
            //button0.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[9][turn]==0 && cupColor[8][turn]==0 && cupColor[4][turn]==0 && cupColor[2][turn]==0 && cupColor[5][turn] != 0) { //Island on cup 1
            island.alpha=1
            islandCups.append(5)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[9][turn]==0 && cupColor[5][turn]==0 && cupColor[4][turn]==0 && cupColor[7][turn]==0 && cupColor[8][turn] != 0) { //Island on cup 2
            island.alpha=1
            islandCups.append(8)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[5][turn]==0 && cupColor[4][turn]==0 && cupColor[0][turn]==0 && cupColor[1][turn]==0 && cupColor[2][turn] != 0) { //Island on cup 3
            island.alpha=1
            islandCups.append(2)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[5][turn]==0 && cupColor[2][turn]==0 && cupColor[1][turn]==0 && cupColor[3][turn]==0 && cupColor[7][turn]==0 && cupColor[8][turn]==0 && cupColor[4][turn] != 0) { //Island on cup 4
            island.alpha=1
            islandCups.append(4)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[8][turn]==0 && cupColor[4][turn]==0 && cupColor[3][turn]==0 && cupColor[6][turn]==0 && cupColor[7][turn] != 0) { //Island on cup 5
            island.alpha=1
            islandCups.append(7)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[2][turn]==0 && cupColor[1][turn]==0 && cupColor[0][turn] != 0) { //Island on cup 6
            island.alpha=1
            islandCups.append(0)
            //button0.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[0][turn]==0 && cupColor[2][turn]==0 && cupColor[4][turn]==0 && cupColor[3][turn]==0 && cupColor[1][turn] != 0) { //Island on cup 7
            island.alpha=1
            islandCups.append(1)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[1][turn]==0 && cupColor[4][turn]==0 && cupColor[7][turn]==0 && cupColor[6][turn]==0 && cupColor[3][turn] != 0) { //Island on cup 8
            island.alpha=1
            islandCups.append(3)
            //button1.layer.borderColor = UIColor.yellow.cgColor;
        }
        if (cupColor[3][turn]==0 && cupColor[7][turn]==0 && cupColor[6][turn] != 0) { //Island on cup 9
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
    func updateIncomingData () {
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
    }
    
    //What happens when a cup is hit
    func cupHit(cupNumber: Int) {
        
        //Increase streak
        currentStreak[turn] += 1
        
        //Classic mode response to cup getting hit
        print("Cup hit!")
        self.cupColor[cupNumber][self.turn] = 0
        self.updateCup(cup: cupNumber)
        
        cupsRemaining[turn] -= 1
        
        //Check for bitch cup
        if (cupsRemaining[turn]==9 && self.cupColor[4][self.turn]==0) {
            createPopup(imageFile: "", titleText: "B*TCH CUP", messageText: "Put yo pants down!", duration: 2)
        }
        
        //Check for ring of death
        if (cupsRemaining[turn]==6 && cupColor[4][turn]==0 && cupColor[0][turn]==0 && cupColor[6][turn]==0 && cupColor[9][turn]==0) {
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
                    if (self.cupColor[i][self.turn] != 0) {
                        self.cupColor[i][self.turn] = 0
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
    
    //What happens when a ball is shot
    func ballShot() {
        print("Ball shot!")
        
        self.totalShots[turn]+=1
        
        if (self.previousShotMade==false) {
            
            //Add the miss move to the undo array
            undo.alpha = 1
            undoArray.append(UndoTurn(moveType: "miss", streakLength: currentStreak[turn]))
            
            //Streak is over
            currentStreak[turn] = 0
            
            //Change the turn
            if (self.turn<3) {
                self.turn+=1
            } else {
                self.turn=0
                self.round+=1
            }
            
            updatePlayerLabel()
            
            AudioServicesPlaySystemSound(1103)
            
        } else {
            //Just a continuation of the shot being made
            self.previousShotMade=false
        }
        
        self.updateCups()
        self.score.text = ("\(self.shotsMade[turn])/\(self.totalShots[turn])")
    }
    
    func updatePlayerLabel() {
        
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
        
        //Pick the background color of the players name and turn label
        if (self.turn==0) {
            let attrString = NSAttributedString(string: "Player \(self.turn+1) Turn #\(self.round)", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: UIColor.red, NSAttributedString.Key.strokeWidth: -7.0])
            self.playerTurn.attributedText = attrString
        } else if (self.turn==1) {
            let attrString = NSAttributedString(string: "Player \(self.turn+1) Turn #\(self.round)", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: UIColor.green, NSAttributedString.Key.strokeWidth: -7.0])
            self.playerTurn.attributedText = attrString
        } else if (self.turn==2) {
            let attrString = NSAttributedString(string: "Player \(self.turn+1) Turn #\(self.round)", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: UIColor.purple, NSAttributedString.Key.strokeWidth: -7.0])
            self.playerTurn.attributedText = attrString
        } else if (self.turn==3) {
            let attrString = NSAttributedString(string: "Player \(self.turn+1) Turn #\(self.round)", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: UIColor.blue, NSAttributedString.Key.strokeWidth: -7.0])
            self.playerTurn.attributedText = attrString
        }
    }
    
    //Sending information back to the ESP
    func outgoingData() {
        let inputString = ("0\(cupColor[0][turn])\(cupColor[1][turn])\(cupColor[2][turn])\(cupColor[3][turn])\(cupColor[4][turn])\(cupColor[5][turn])\(cupColor[6][turn])\(cupColor[7][turn])\(cupColor[8][turn])\(cupColor[9][turn])")
        writeValue(data: inputString)
    }
    
    func writeValue(data: String){
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        //change the "data" to valueString
        if let blePeripheral = blePeripheral{
            if let txCharacteristic = txCharacteristic {
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    //Set the cup and UI button stylings
    func styleButton() {
        for i in 0...9 {
            cupButtons[i].layer.borderColor = UIColor.white.cgColor;
            cupButtons[i].layer.borderWidth = 5;
            cupButtons[i].backgroundColor = UIColor.black;
            cupButtons[i].layer.cornerRadius = UIScreen.main.bounds.size.width/12;
            //cupButtons[i].titleLabel?.font = UIFont(name: "Aldrich-Regular", size: 20)
            //cupButtons[i].setTitle("$30k", for: [])
            cupButtons[i].titleLabel?.adjustsFontSizeToFitWidth = true
        }
        
        undo.layer.borderColor = UIColor.white.cgColor;
        undo.layer.borderWidth = 3;
        undo.layer.cornerRadius = 3
        undo.alpha = 0.25
        
        miss.layer.borderColor = UIColor.white.cgColor;
        miss.layer.borderWidth = 3;
        miss.layer.cornerRadius = 3
        miss.alpha = 1
        
        rerack.layer.borderColor = UIColor.white.cgColor;
        rerack.layer.borderWidth = 3;
        rerack.layer.cornerRadius = 3
        rerack.alpha = 0.25
        
        island.layer.borderColor = UIColor.white.cgColor;
        island.layer.borderWidth = 3;
        island.layer.cornerRadius = 3;
        island.alpha = 0.25
    }
    
    
    
    //Update all cups
    func updateCups() {
        //Update the cup buttons
        for i in 0...9 {
            if cupColor[i][turn] == 0 {
                cupButtons[i].backgroundColor = UIColor.black;
            } else if cupColor[i][turn] == 1 {
                cupButtons[i].backgroundColor = UIColor.red;
            } else if cupColor[i][turn] == 2 {
                cupButtons[i].backgroundColor = UIColor.green;
            } else if cupColor[i][turn] == 3 {
                cupButtons[i].backgroundColor = UIColor.purple;
            } else if cupColor[i][turn] == 4 {
                cupButtons[i].backgroundColor = UIColor.blue;
            }
        }
    }
    
    //Update one cup
    func updateCup(cup: Int) {
        //Update the cup buttons
        if cupColor[cup][turn] == 0 {
            cupButtons[cup].backgroundColor = UIColor.black;
        } else if cupColor[cup][turn] == 1 {
            cupButtons[cup].backgroundColor = UIColor.red;
        } else if cupColor[cup][turn] == 2 {
            cupButtons[cup].backgroundColor = UIColor.green;
        } else if cupColor[cup][turn] == 3 {
            cupButtons[cup].backgroundColor = UIColor.purple;
        } else if cupColor[cup][turn] == 4 {
            cupButtons[cup].backgroundColor = UIColor.blue;
        }
    }
    
    //This starts the timer to execute updateCounting every second
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    //THIS GETS RUN EVERY SECOND
    @objc func updateCounting(){
        //print(timeElapsed)
        timeElapsed[turn]+=1
        //Display the time and convert to minutes and seconds for display
        if ((timeElapsed[turn]%60)<10) {
            time.text = ("\(timeElapsed[turn]/60):0\(timeElapsed[turn]%60)")
        } else {
            time.text = ("\(timeElapsed[turn]/60):\(timeElapsed[turn]%60)")
        }
    }
    
    //If bluetooth on phone is turned on or off
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        if peripheral.state == .poweredOff {
            //disconnectDevice()
        }
        print("Peripheral manager is running")
    }
    
    //Disconnecting from bluetooth device --> navigate back to pairing screen
    /*func disconnectDevice() {
        //Go back to the pairing screen
        navigationController?.dismiss(animated: false, completion: nil)
        navigationController?.popViewController(animated: false)
        timer.invalidate()
    }*/
}
