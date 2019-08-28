//
//  ViewControllerGamemode.swift
//  Planet Pong
//
//  The parent class of all the gamemode view controllers
//
//  Created by Mac on 8/21/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation
import UIKit
import CoreBluetooth
import StatusAlert

//The object holding the information for one move
class UndoTurn {
    var moveType = ""
    var cupChanged = 0
    var prevCupColor = 0
    var cupConfiguration = [Int]()
    var streakLength = 0
    var cupConfigurationAll = [[Int]]()
    var activePlayers = [Int]()
    var finalRound = -1
    var lastCup = -1
    var cupsRemaining = [Int]()
    
    //CONSTRUCTORS FOR THE DIFFERENT TYPES OF UNDO MOVES
    
    init(moveType: String, cupConfiguration: [Int]) {
        self.moveType = moveType
        self.cupConfiguration = cupConfiguration
    }
    
    init(moveType: String, cupChanged: Int) {
        self.moveType = moveType
        self.cupChanged = cupChanged
    }
    
    init(moveType: String, cupChanged: Int, prevCupColor: Int) {
        self.moveType = moveType
        self.cupChanged = cupChanged
        self.prevCupColor = prevCupColor
    }
    
    init(moveType: String) {
        self.moveType = moveType
    }
    
    init(moveType: String, streakLength: Int) {
        self.moveType = moveType
        self.streakLength = streakLength
    }
    
    //Rebutal
    init(moveType: String, cupConfigurationAll: [[Int]], activePlayers: [Int], finalRound: Int, lastCup: Int, cupsRemaining: [Int]) {
        self.moveType = moveType
        self.cupConfigurationAll = cupConfigurationAll
        self.activePlayers = activePlayers
        self.finalRound = finalRound
        self.lastCup = lastCup
        self.cupsRemaining = cupsRemaining
    }
}

class ViewControllerGamemode: SpaceVibe, CBPeripheralManagerDelegate {
    
    //UI Elements
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
    
    //Vital for bluetooth
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        if peripheral.state == .poweredOff {
            //disconnectDevice()
        }
        print("Peripheral manager is running")
    }
    
    //Bluetooth Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    var centralManager : CBCentralManager!
    var central: CBCentralManager?
    var bluetoothEnabled = true
    var ratchetFix = false //A fix for a carry over BLE signal, not exactly sure why it happens as of now
    var observer: NSObjectProtocol! //Observer notification for incoming BLE strings
    
    //Array of the cups
    lazy var cupButtons = [UIButton]();
    //Array of cup colors
    var cupColor = [Int]();
    var cupColorMultiple = [[Int]]()
    var boardType = "single" //Can be single or multiple depending on the gamemode, set in viewDidLoad
    
    //Players
    var numPlayers = 4
    var playerNames = ["PLAYER 1","PLAYER 2","PLAYER 3", "PLAYER 4"]
    var activePlayers = [1, 1, 1, 1]
    var playerColors = [UIColor.red, UIColor.green, UIColor.purple, UIColor.blue]
    var playerColorsNum = [1, 2, 3, 4]
    var playerPerTeam = 1
    
    //Tracking how many cups each player has, useful for some gamemodes
    var cupsRemaining = [1, 1, 1, 1]
    
    //Turns & Rounds
    var firstPlayer = 0
    var turn = 0 //The turn of the player currently going
    var round = 1 //The current round
    var previousShotMade = false //If the previous shot was made or not, useful for detecting a miss from the unit
    
    //Timer
    var timer = Timer()
    var timeElapsed = [0, 0, 0, 0] //Time elapsed per player per game
    
    //Score keeping
    var totalShots = [0, 0, 0, 0] //Makes + misses
    var shotsMade = [0, 0, 0, 0] //Makes
    
    //Undo array
    var undoArray = [UndoTurn]()
    
    //Streak
    var currentStreak = [0, 0, 0, 0]
    
    //Paused
    var isPaused = false
    var blackOverlay:UIView?
    var quitButton:UIButton?
    
    //Game condition
    var lastCup = -1
    var finalRound = -1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Set player colors
        if (playerPerTeam == 2) {
            playerColors = [UIColor.red, UIColor.red, UIColor.green, UIColor.green]
        }
        
        //Initialize the cups array with the button handles
        cupButtons = [button6, button7, button3, button8, button4, button1, button9, button5, button2, button0];
        
        //Start timer
        scheduledTimerWithTimeInterval()
        
        //Get the UI right
        styleButton()
        view.setNeedsDisplay()
        
        //Get bluetooth right
        if (bluetoothEnabled) {
            //Create and start the peripheral manager
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            
            //-Notification for updating the text view with incoming text
            updateIncomingData()
        } else {
            //Initialize labels
            /*let attrString = NSAttributedString(string: "\(playerNames[0]) Turn #1", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: UIColor.red, NSAttributedString.Key.strokeWidth: -7.0])
             self.playerTurn.attributedText = attrString*/
            updatePlayerLabelOnly()
        }
        
        initPauseMenu()
        
    }
    
    //Happens AFTER viewDidLoad when the screen actually appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ratchetFix = false
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
        //print("Disconnecting, so now removing observer and timer from gamemode classic")
        //NotificationCenter.default.removeObserver(self)
        timer.invalidate()
    }
    
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
    
    //UI CUP BUTTON PRESSES
    @IBAction func button0Press(_ sender: Any) {
        self.cupHit(cupNumber: 9)
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    @IBAction func button1Press(_ sender: Any) {
        self.cupHit(cupNumber: 5)
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    @IBAction func button2Press(_ sender: Any) {
        self.cupHit(cupNumber: 8)
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    @IBAction func button3Press(_ sender: Any) {
        self.cupHit(cupNumber: 2)
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    @IBAction func button4Press(_ sender: Any) {
        self.cupHit(cupNumber: 4)
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    @IBAction func button5Press(_ sender: Any) {
        self.cupHit(cupNumber: 7)
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    @IBAction func button6Press(_ sender: Any) {
        self.cupHit(cupNumber: 0)
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    @IBAction func button7Press(_ sender: Any) {
        self.cupHit(cupNumber: 1)
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    @IBAction func button8Press(_ sender: Any) {
        self.cupHit(cupNumber: 3)
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    @IBAction func button9Press(_ sender: Any) {
        self.cupHit(cupNumber: 6)
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }
    
    @IBAction func missButtonPress(_ sender: Any) {
        self.previousShotMade = false
        self.ballShot()
        if (bluetoothEnabled) {
            self.outgoingData()
        }
    }

    //This starts the timer to execute updateCounting every second
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    //THIS GETS RUN EVERY SECOND
    @objc func updateCounting(){
        
        if (isPaused) {
            return
        }
        
        //print(timeElapsed)
        timeElapsed[turn]+=1
        //Display the time and convert to minutes and seconds for display
        if ((timeElapsed[turn]%60)<10) {
            time.text = ("\(timeElapsed[turn]/60):0\(timeElapsed[turn]%60)")
        } else {
            time.text = ("\(timeElapsed[turn]/60):\(timeElapsed[turn]%60)")
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
    
    //Update all cups
    func updateCups() {
        //Update the cup buttons
        
        if (boardType == "single") {
            for i in 0...9 {
                if cupColor[i] == 0 {
                    cupButtons[i].backgroundColor = UIColor.black;
                } else if cupColor[i] == 1 {
                    cupButtons[i].backgroundColor = UIColor.red;
                } else if cupColor[i] == 2 {
                    cupButtons[i].backgroundColor = UIColor.green;
                } else if cupColor[i] == 3 {
                    cupButtons[i].backgroundColor = UIColor.purple;
                } else if cupColor[i] == 4 {
                    cupButtons[i].backgroundColor = UIColor.blue;
                }
            }
        } else if (boardType == "multiple") {
            for i in 0...9 {
                if cupColorMultiple[i][self.turn] == 0 {
                    cupButtons[i].backgroundColor = UIColor.black;
                } else if cupColorMultiple[i][self.turn] == 1 {
                    cupButtons[i].backgroundColor = UIColor.red;
                } else if cupColorMultiple[i][self.turn] == 2 {
                    cupButtons[i].backgroundColor = UIColor.green;
                } else if cupColorMultiple[i][self.turn] == 3 {
                    cupButtons[i].backgroundColor = UIColor.purple;
                } else if cupColorMultiple[i][self.turn] == 4 {
                    cupButtons[i].backgroundColor = UIColor.blue;
                }
            }
        }
    }
    
    //Update one cup
    func updateCup(cup: Int) {
        //Update the cup buttons
        
        if (boardType == "single") {
            if cupColor[cup] == 0 {
                cupButtons[cup].backgroundColor = UIColor.black;
            } else if cupColor[cup] == 1 {
                cupButtons[cup].backgroundColor = UIColor.red;
            } else if cupColor[cup] == 2 {
                cupButtons[cup].backgroundColor = UIColor.green;
            } else if cupColor[cup] == 3 {
                cupButtons[cup].backgroundColor = UIColor.purple;
            } else if cupColor[cup] == 4 {
                cupButtons[cup].backgroundColor = UIColor.blue;
            }
        } else if (boardType == "multiple") {
            if cupColorMultiple[cup][self.turn] == 0 {
                cupButtons[cup].backgroundColor = UIColor.black;
            } else if cupColorMultiple[cup][self.turn] == 1 {
                cupButtons[cup].backgroundColor = UIColor.red;
            } else if cupColorMultiple[cup][self.turn] == 2 {
                cupButtons[cup].backgroundColor = UIColor.green;
            } else if cupColorMultiple[cup][self.turn] == 3 {
                cupButtons[cup].backgroundColor = UIColor.purple;
            } else if cupColorMultiple[cup][self.turn] == 4 {
                cupButtons[cup].backgroundColor = UIColor.blue;
            }
        }
    }
    
    func updatePlayerLabelOnly() {
        if (self.turn==0) {
            let attrString = NSAttributedString(string: "\(playerNames[0]) Turn #\(self.round)", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: playerColors[self.turn], NSAttributedString.Key.strokeWidth: -7.0])
            self.playerTurn.attributedText = attrString
        } else if (self.turn==1) {
            let attrString = NSAttributedString(string: "\(playerNames[1]) Turn #\(self.round)", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: playerColors[self.turn], NSAttributedString.Key.strokeWidth: -7.0])
            self.playerTurn.attributedText = attrString
        } else if (self.turn==2) {
            let attrString = NSAttributedString(string: "\(playerNames[2]) Turn #\(self.round)", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: playerColors[self.turn], NSAttributedString.Key.strokeWidth: -7.0])
            self.playerTurn.attributedText = attrString
        } else if (self.turn==3) {
            let attrString = NSAttributedString(string: "\(playerNames[3]) Turn #\(self.round)", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: playerColors[self.turn], NSAttributedString.Key.strokeWidth: -7.0])
            self.playerTurn.attributedText = attrString
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
                self.updatePlayerLabelOnly()
                
                self.updateCups()
            } else {
                if (!self.isPaused) {
                    let incomingString = (characteristicASCIIValue as String)
                    print(incomingString)
                    
                    //PARSE THE INCOMING VALUE
                    //IF CUP HIT
                    if (incomingString[incomingString.index(incomingString.startIndex, offsetBy: 0)] == "0") {
                        let cupNum = Int(String(incomingString[incomingString.index(incomingString.startIndex, offsetBy: 1)]))
                        
                        self.cupHit(cupNumber: cupNum ?? 0)
                        
                        self.previousShotMade = true
                        
                        self.outgoingData()
                    }
                    
                    //IF TOTAL BALLS SHOT INCREMENTED
                    if (incomingString[incomingString.index(incomingString.startIndex, offsetBy: 0)] == "1") {
                        self.ballShot()
                        self.outgoingData()
                    }
                }
            }
        }
    }
    
    //Sending information back to the ESP
    func outgoingData() {
        
        var inputString = ""
        
        if (boardType == "single") {
            inputString = ("0\(cupColor[0])\(cupColor[1])\(cupColor[2])\(cupColor[3])\(cupColor[4])\(cupColor[5])\(cupColor[6])\(cupColor[7])\(cupColor[8])\(cupColor[9])")
        } else if (boardType == "multiple") {
            inputString = ("0\(cupColorMultiple[0][self.turn])\(cupColorMultiple[1][self.turn])\(cupColorMultiple[2][self.turn])\(cupColorMultiple[3][self.turn])\(cupColorMultiple[4][self.turn])\(cupColorMultiple[5][self.turn])\(cupColorMultiple[6][self.turn])\(cupColorMultiple[7][self.turn])\(cupColorMultiple[8][self.turn])\(cupColorMultiple[9][self.turn])")
        }
        
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
    
    //Code that runs to update player labels as well as other things that update when the turn changes
    func updatePlayerLabel() {
        
        updatePlayerLabelOnly()
    
    }
    
    func cupHit(cupNumber: Int) {
        
    }
    
    func ballShot() {
        self.totalShots[turn] += 1
    }
    
    //Algorithm to check for isolated cups
    func islandCheck() {
        
    }
    
    //Goes to the next turn
    func nextTurn() {
        //Change the turn
        if (self.turn<numPlayers-1) {
            self.turn+=1
        } else {
            self.turn=0
        }
        
        if (self.turn == firstPlayer) {
            print("next round")
            self.round+=1
        }
        
        //Make sure to go to the next ACTIVE player
        while (activePlayers[self.turn] == 0) {
            print("skipping a turn")
            if (self.turn<numPlayers-1) {
                self.turn+=1
            } else {
                self.turn=0
            }
            
            if (self.turn == firstPlayer) {
                print("next round")
                self.round+=1
            }
        }
    }
    
    //Switches to the previous turn
    func prevTurn() {
        if (self.turn==firstPlayer) {
            self.round-=1
        }
        
        //Undo the turn change
        if (self.turn>0) {
            self.turn-=1
        } else {
            self.turn=numPlayers-1
        }
        
        //Make sure to go to the next ACTIVE player
        while (activePlayers[self.turn] == 0) {
            
            if (self.turn==firstPlayer) {
                self.round-=1
            }
            
            if (self.turn>0) {
                self.turn-=1
            } else {
                self.turn=numPlayers-1
            }
        }
    }
    
    @objc func pausePressed() {
        if (isPaused) {
            isPaused = false
            blackOverlay!.isHidden = true
            quitButton!.isHidden = true
        } else {
            isPaused = true
            blackOverlay!.isHidden = false
            quitButton!.isHidden = false
        }
    }
    
    @objc func quitPressed() {
        fadeOutAnimationPopTo(vc: self.navigationController!.viewControllers[0])
    }
    
    func initPauseMenu() {
        
        //Create black overlay for when the pause button is pressed
        blackOverlay = UIView(frame: self.view.frame)
        blackOverlay!.backgroundColor = UIColor.black
        blackOverlay!.alpha = 0.9
        blackOverlay!.isHidden = true
        self.view.addSubview(blackOverlay!)
        
        blackOverlay!.translatesAutoresizingMaskIntoConstraints = false
        /*imageViewStars1?.translatesAutoresizingMaskIntoConstraints = false
        //Set the constraint of the stars
        let margins = self.view.layoutMarginsGuide
        imageViewStars!.heightAnchor.constraint(equalTo: margins.heightAnchor).isActive = true
        imageViewStars!.widthAnchor.constraint(equalTo: imageViewStars!.heightAnchor).isActive = true
        xAxisConstraint = imageViewStars!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: CGFloat(starsPosition))
        xAxisConstraint?.isActive = true
        imageViewStars!.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        imageViewStars!.layer.zPosition = -100*/
        
        //Create the pause button in the upper right
        let pauseButton = UIButton(type: .custom)
        pauseButton.setTitle("", for: .normal)
        pauseButton.setImage(UIImage(named: "PauseIcon"), for: .normal)
        pauseButton.layer.zPosition = 1000
        pauseButton.setTitleColor(UIColor.darkGray, for: UIControl.State.highlighted)
        pauseButton.addTarget(self,
                              action: #selector(pausePressed),
                              for: .touchUpInside)
        //let button = UIButton(type: .custom)
        //button.backgroundColor = .red
        self.view.addSubview(pauseButton)
        
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.15).isActive = true
        pauseButton.heightAnchor.constraint(equalTo: pauseButton.widthAnchor).isActive = true
        pauseButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
        pauseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        
        //Create the quit button in the center of the screen
        quitButton = UIButton(type: .custom)
        quitButton!.setTitle("QUIT?", for: .normal)
        quitButton!.layer.zPosition = 1000
        quitButton!.layer.borderColor = UIColor.white.cgColor;
        quitButton!.layer.borderWidth = 3;
        quitButton!.layer.cornerRadius = 3;
        quitButton!.setTitleColor(UIColor.darkGray, for: UIControl.State.highlighted)
        quitButton!.addTarget(self,
                              action: #selector(quitPressed),
                              for: .touchUpInside)
        
        self.view.addSubview(quitButton!)
        
        quitButton!.translatesAutoresizingMaskIntoConstraints = false
        quitButton!.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.65).isActive = true
        quitButton!.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
        quitButton!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        quitButton!.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        quitButton!.isHidden = true
    }
}
