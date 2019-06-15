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

import UIKit
import CoreBluetooth

class ViewControllerPlanetPong: UIViewController, CBPeripheralManagerDelegate {
    
    
    /*func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            //
        } else {
            print("NOaked")
            disconnectDevice()
        }
    }*/
    

    //UI
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
    
    @IBOutlet weak var island: UIButton!
    @IBOutlet weak var rerack: UIButton!
    
    //Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    var centralManager : CBCentralManager!
    
    var central: CBCentralManager?
    
    lazy var cupButtons = [UIButton]();
    var cupColor = [Int]();
    
    //Ratchet Fix
    var ratchetFix = false
    
    //Timer
    var timer = Timer()
    var timeElapsed = 0 //In seconds
    
    //Score
    var totalShots = 0
    var shotsMade = 0
    
    //RUN WIHEN VIEW LOADS
    override func viewDidLoad() {
        //Ratchet Fix
        ratchetFix = false
        
        //Timer
        timeElapsed = 0
        
        //Score
        totalShots = 0
        shotsMade = 0
        
        //Array of button objects
        cupButtons = [button6, button7, button3, button8, button4, button1, button9, button5, button2, button0];
        
        //cupButtons = [button0, button1, button2, button3, button4, button5, button6, button7, button8, button9];
        
        //CUP ARRAYS
        cupColor = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]; //Set all cup colors to green
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
    
    func viewDidAppear() {
        ratchetFix = false
        styleButton()
    }
    
    //Checks if there is an incoming string from the ESP32 and then prints it out on the console if there is one
    func updateIncomingData () {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            if (self.ratchetFix == false) {
                self.ratchetFix = true
                //Set initial cups
                let inputText = ("0\(self.cupColor[0])\(self.cupColor[1])\(self.cupColor[2])\(self.cupColor[3])\(self.cupColor[4])\(self.cupColor[5])\(self.cupColor[6])\(self.cupColor[7])\(self.cupColor[8])\(self.cupColor[9])")
                self.writeValue(data: inputText)
                
                self.updateCups()
            } else {
                let incomingString = (characteristicASCIIValue as String)
                print(incomingString)
                
                //PARSE THE INCOMING VALUE
                //IF CUP HIT
                if (incomingString[incomingString.index(incomingString.startIndex, offsetBy: 0)] == "0") {
                    print("Cup hit!")
                    let cupNum = Int(String(incomingString[incomingString.index(incomingString.startIndex, offsetBy: 1)]))

                    //Update the cup color accordingly
                    self.cupColor[cupNum ?? 0] = Int.random(in: 1 ... 4)
                    self.updateCup(cup: cupNum ?? 0)
                    
                    self.shotsMade+=1
                    
                    self.score.text = ("Score: \(self.shotsMade)/\(self.totalShots)")
                    
                    //Respond to the ESP32
                    let inputText = ("0\(self.cupColor[0])\(self.cupColor[1])\(self.cupColor[2])\(self.cupColor[3])\(self.cupColor[4])\(self.cupColor[5])\(self.cupColor[6])\(self.cupColor[7])\(self.cupColor[8])\(self.cupColor[9])")
                    self.writeValue(data: inputText)
                }
                
                //IF TOTAL BALLS SHOT INCREMENTED
                if (incomingString[incomingString.index(incomingString.startIndex, offsetBy: 0)] == "1") {
                    print("Ball shot!")
                    
                    self.totalShots+=1
                    
                    self.score.text = ("Score: \(self.shotsMade)/\(self.totalShots)")
                }
                
            }
        }
    }
    
    // Write functions --> ESP32
    //Write a string from the text box
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
            cupButtons[i].layer.cornerRadius = 30;
        }
        
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
        playerTurn.shadowColor = UIColor.green
    }
    
    //Update one cup
    func updateCup(cup: Int) {
        //Update the cup buttons
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
    }
    
    //This starts the timer to execute updateCounting every second
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    //THIS GETS RUN EVERY SECOND
    @objc func updateCounting(){
        print(timeElapsed)
        timeElapsed+=1
        time.text = ("Time: \(timeElapsed)")
    }
    
    //If bluetooth on phone is turned on or off
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        if peripheral.state == .poweredOff {
            disconnectDevice()
        }
        print("Peripheral manager is running")
    }
    
    //Disconnecting from bluetooth device --> navigate back to pairing screen
    func disconnectDevice() {
        //Go back to the pairing screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let uartViewController = storyboard.instantiateViewController(withIdentifier: "BLECentralViewController") as! BLECentralViewController
        navigationController?.dismiss(animated: false, completion: nil)
        navigationController?.popViewController(animated: false)
        timer.invalidate()
    }
}
