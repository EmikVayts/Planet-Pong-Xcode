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

class ViewControllerGamemodeClassic: UIViewController, CBPeripheralManagerDelegate {
    
    
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
    
    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var miss: UIButton!
    
    @IBOutlet weak var island: UIButton!
    @IBOutlet weak var rerack: UIButton!
    
    //Bluetooth Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    var centralManager : CBCentralManager!
    
    var central: CBCentralManager?
    
    lazy var cupButtons = [UIButton]();
    //Single player gamemode
    var cupColor = [[Int]]();
    
    //Multiplayer gamemode --> Different array for each player
    var cupColor1 = [Int]();
    var cupColor2 = [Int]();
    var cupColor3 = [Int]();
    var cupColor4 = [Int]();
    
    var turn = 0 //The turn of the player currently going
    var round = 1 //The current round
    var previousShotMade = false
    
    //Ratchet Fix - prevents the BLE signal to carry over from the previous game
    var ratchetFix = false
    
    //Observer for incoming BLE strings
    var observer: NSObjectProtocol!
    
    //Timer
    var timer = Timer()
    var timeElapsed = 0 //In seconds
    
    //Score
    var totalShots = 0
    var shotsMade = 0
    var scorePoints = 0
    
    //RUN WIHEN VIEW LOADS
    override func viewDidLoad() {

        //Ratchet Fix
        ratchetFix = false
        
        //Timer
        timeElapsed = 0
        
        //Score
        totalShots = 0
        shotsMade = 0
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
        
        updateCups()
        
        //Start timer
        scheduledTimerWithTimeInterval()
        
        //Update score
        
        super.viewDidLoad()
        styleButton();
        
        view.setNeedsDisplay();
        //cup0Button.backgroundColor = UIColor.green;
        // Do any additional setup after loading the view, typically from a nib.
        
        //Create and start the peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        //-Notification for updating the text view with incoming text
        updateIncomingData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ratchetFix = false
        styleButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.peripheralManager?.stopAdvertising()
        //self.peripheralManager = nil
        super.viewDidDisappear(animated)
        print("Disconnecting, so now removing observer and timer from gamemode classic")
        //NotificationCenter.default.removeObserver(self)
        timer.invalidate()
        NotificationCenter.default.removeObserver(observer)
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
                    print("Cup hit!")
                    let cupNum = Int(String(incomingString[incomingString.index(incomingString.startIndex, offsetBy: 1)]))

                    //Classic mode response to cup getting hit
                    self.cupColor[cupNum ?? 0][self.turn] = 0
                    self.updateCup(cup: cupNum ?? 0)
                    
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
                    
                    self.previousShotMade = true
                    
                    self.shotsMade+=1
                    
                    //Vibrate the phone as positive reinforcement
                    AudioServicesPlaySystemSound(1013)
                    
                    self.outgoingData()
                    
                    self.score.text = ("Score: \(self.shotsMade)/\(self.totalShots)")
                    
                    //Respond to the ESP32
                    /*let inputText = ("0\(self.cupColor[0])\(self.cupColor[1])\(self.cupColor[2])\(self.cupColor[3])\(self.cupColor[4])\(self.cupColor[5])\(self.cupColor[6])\(self.cupColor[7])\(self.cupColor[8])\(self.cupColor[9])")
                    self.writeValue(data: inputText)*/
                }
                
                //IF TOTAL BALLS SHOT INCREMENTED
                if (incomingString[incomingString.index(incomingString.startIndex, offsetBy: 0)] == "1") {
                    print("Ball shot!")
                    
                    self.totalShots+=1
                    
                    if (self.previousShotMade==false) {
                        if (self.turn<3) {
                            self.turn+=1
                        } else {
                            self.turn=0
                            self.round+=1
                        }

                        let attrString = NSAttributedString(string: "Player \(self.turn+1) Turn #\(self.round)", attributes: [NSAttributedString.Key.strokeColor: UIColor.white, NSAttributedString.Key.backgroundColor: UIColor.red, NSAttributedString.Key.strokeWidth: -7.0])
                        
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
                        
                        AudioServicesPlaySystemSound(1103)
                        
                    } else {
                        self.previousShotMade=false
                    }
                    
                    self.updateCups()
                    
                    self.outgoingData()
                    
                    self.score.text = ("Score: \(self.shotsMade)/\(self.totalShots)")
                    
                }
            }
        }
    }
    
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
    
    //Set the corner radius and all
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
        undo.alpha = 0.5
        
        miss.layer.borderColor = UIColor.white.cgColor;
        miss.layer.borderWidth = 3;
        miss.layer.cornerRadius = 3
        miss.alpha = 0.5
        
        rerack.layer.borderColor = UIColor.white.cgColor;
        rerack.layer.borderWidth = 3;
        rerack.layer.cornerRadius = 3
        rerack.alpha = 0.5
        
        island.layer.borderColor = UIColor.white.cgColor;
        island.layer.borderWidth = 3;
        island.layer.cornerRadius = 3;
        island.alpha = 0.5
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
        timeElapsed+=1
        //Display the time and convert to minutes and seconds for display
        if ((timeElapsed%60)<10) {
            time.text = ("Time: \(timeElapsed/60):0\(timeElapsed%60)")
        } else {
            time.text = ("Time: \(timeElapsed/60):\(timeElapsed%60)")
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
