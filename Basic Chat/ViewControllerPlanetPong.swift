//
//  ViewController.swift
//  PlanetPongGUI
//
//  Created by Emik Vayts on 4/5/19.
//  Copyright © 2019 Emik Vayts. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class ViewControllerPlanetPong: UIViewController {

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
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var score: UITextField!
    
    //Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    
    lazy var cupButtons = [UIButton]();
    var cupColor = [Int]();
    
    var timer = Timer()
    
    override func viewDidLoad() {
        cupButtons = [button0, button1, button2, button3, button4, button5, button6, button7, button8, button9];
        
        //CUP ARRAYS
        cupColor = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3]; //Set all cup colors to blue
        
        //Start timer
        scheduledTimerWithTimeInterval()
        
        //Update score
        
        
        super.viewDidLoad()
        styleButton();
        
        view.setNeedsDisplay();
        //cup0Button.backgroundColor = UIColor.green;
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func styleButton() {
        for i in 0...9 {
            cupButtons[i].backgroundColor = UIColor.blue;
            cupButtons[i].layer.cornerRadius = 25;
        }
    }
    
    //Update all cups
    func updateCups() {
        //Update the cup buttons
        for i in 0...9 {
            if cupColor[i] == 0 {
                cupButtons[i].backgroundColor = UIColor.red;
            } else if cupColor[i] == 1 {
                cupButtons[i].backgroundColor = UIColor.green;
            } else if cupColor[i] == 2 {
                cupButtons[i].backgroundColor = UIColor.purple;
            } else if cupColor[i] == 3 {
                cupButtons[i].backgroundColor = UIColor.blue;
            }
        }
    }
    
    //Update one cup
    func updateCup(cup: Int) {
        //Update the cup buttons
            if cupColor[cup] == 0 {
                cupButtons[cup].backgroundColor = UIColor.red;
            } else if cupColor[cup] == 1 {
                cupButtons[cup].backgroundColor = UIColor.green;
            } else if cupColor[cup] == 2 {
                cupButtons[cup].backgroundColor = UIColor.purple;
            } else if cupColor[cup] == 3 {
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
        NSLog("counting..")
    }
}
