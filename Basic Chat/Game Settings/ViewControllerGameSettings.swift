//
//  ViewControllerGameSettings.swift
//  Planet Pong
//
//  Created by Mac on 6/10/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

//TODO: Ben

import Foundation
import UIKit

class ViewControllerGameSettings : UIViewController, UITextFieldDelegate {
    //UI Objects
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var numberOfPlayers: UITextField!
    @IBOutlet weak var nameLabel4: UILabel!
    @IBOutlet weak var nameLabel3: UILabel!
    @IBOutlet weak var nameLabel2: UILabel!
    @IBOutlet weak var nameLabel1: UILabel!
    @IBOutlet weak var nameInput4: UITextField!
    @IBOutlet weak var nameInput3: UITextField!
    @IBOutlet weak var nameInput2: UITextField!
    @IBOutlet weak var nameInput1: UITextField!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    

    @IBOutlet weak var blueBacking: UIView!
    @IBOutlet weak var purpleBacking: UIView!
    @IBOutlet weak var greenBacking: UIView!
    @IBOutlet weak var redBacking: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var buttonRandom: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Constraints
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    //Bluetooth
    var bluetoothEnabled = false
    
    //actions
    @IBAction func backButton(_ sender: Any) {
        let screenTransition = ScreenTransitions()
        
        screenTransition.popScreen(nc: navigationController!)
    }
    
    @IBAction func randomButton(_ sender: Any){
        if (activeField != nil) {
            let firstName = ["Big", "Yeller", "Yoited", "Fat", "Juicy", "Full", "Crazy", "Cash", "Sad", "Yay", "Giant", "Ugly", "Special", "Lil", "Silly", "Hot", "Nice", "Magic", "Clean", "Sugar", "Salty", "Young", "Wide", "Single", "Sexy", "Mega", "Tasty", "Mama", "Father", "Funny", "Fast", "Dank", "Wet", "Fire", "Lit", "Fly", "Clutch", "Magnum", "Small", "Psycho", "Party", "Poopy", "Good", "Rowdy", "Girly", "Funky", "Trigga", "Space", "Sir", "Miss", "Dilly", "Ya", "Yee", "Chunky", "Mighty", "Dark", "Bloody", "Lethal", "Freaky", "Super", "Slow", "Tall", "Short", "Classy", "Drunk", "Wasted", "Boom", "Pregnant", "Double", "Frat", "Beer", "Cool", "Triple", "Smelly", "Grumpy", "The", "A"]
            let lastName = ["Mep", "Load", "Jelly", "Nibby", "Kermit", "Marmes", "Mama", "Papa", "Squared", "Frog", "Nut", "Send", "Money", "Dump", "Guy", "Daddy", "Fetus", "Mommy", "Girl", "Time", "People", "Club", "Baller", "Shooter", "Sniper", "Diaper", "Player", "Dupes", "Bling", "Tank", "Beast", "Goat", "Mix", "Chop", "Dupes", "Manny", "Ween", "Chap", "Baf", "Golfer", "Piss", "Bunch", "Power", "Pong", "Planet", "Blunt", "Beats", "Dilly", "Yeet", "Dog", "Snake", "Clown", "King", "Slam", "Chug", "Duck", "Cat", "Kitty", "Kiki", "Love", "Man", "Gun", "Yoit", "Ligun", "Bigun", "Freak", "Meep", "Crayon", "Freshman", "Sophomore", "Junior", "Senior", "Teacher", "Blonde", "Midget", "Mess", "Fight", "Blaw", "Bang", "Party", "Fool", "Zoom", "Stick", "Juul", "Vape", "Whammy", "Frat", "Nerd", "Jock", "Dangle", "Tart", "Pickle", "Toast", "Twerk"]
            
            let firstNameFinal = firstName.randomElement()
            
            let lastNameFinal = lastName.randomElement()
            
            activeField?.text = "\(firstNameFinal!) \(lastNameFinal!)"
        }
    }
    
    
    @IBAction func startButtonPress(_ sender: Any) {
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (activeField == nameInput1) {
            redBacking.alpha = 0.25
        } else if (activeField == nameInput2) {
            greenBacking.alpha = 0.25
        } else if (activeField == nameInput3) {
            purpleBacking.alpha = 0.25
        } else if (activeField == nameInput4) {
            blueBacking.alpha = 0.25
        }
        
        activeField = textField
        
        if (activeField == nameInput1) {
            redBacking.alpha = 1
        } else if (activeField == nameInput2) {
            greenBacking.alpha = 1
        } else if (activeField == nameInput3) {
            purpleBacking.alpha = 1
        } else if (activeField == nameInput4) {
            blueBacking.alpha = 1
        }
        
        //lastOffset = self.ScrollView.contentOffset
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (activeField == nameInput1) {
            redBacking.alpha = 0.25
        } else if (activeField == nameInput2) {
            greenBacking.alpha = 0.25
        } else if (activeField == nameInput3) {
            purpleBacking.alpha = 0.25
        } else if (activeField == nameInput4) {
            blueBacking.alpha = 0.25
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        buttonRandom.alpha = 0
        
        /*UIView.animate(withDuration: 0.3) {
            self.constraintContentHeight.constant -= self.keyboardHeight
            
            self.ScrollView.contentOffset = self.lastOffset
        }
        
        keyboardHeight = nil*/
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        buttonRandom.alpha = 1
        
        /*if keyboardHeight != nil {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintContentHeight.constant += self.keyboardHeight
            })
            // move if keyboard hide input field
            let distanceToBottom = self.ScrollView.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!
            let collapseSpace = keyboardHeight - distanceToBottom
            if collapseSpace < 0 {
                // no collapse
                return
            }
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.ScrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }*/
    }
    
    func changeNumPlayers(){
        if (numPlayers == 1){
            nameLabel2.alpha = 0
            nameLabel3.alpha = 0
            nameLabel4.alpha = 0
            nameInput2.alpha = 0
            nameInput3.alpha = 0
            nameInput4.alpha = 0
            greenBacking.alpha = 0
            purpleBacking.alpha = 0
            blueBacking.alpha = 0
        }
        else if (numPlayers == 2){
            nameLabel2.alpha = 1
            nameLabel3.alpha = 0
            nameLabel4.alpha = 0
            nameInput2.alpha = 1
            nameInput3.alpha = 0
            nameInput4.alpha = 0
            greenBacking.alpha = 0.25
            purpleBacking.alpha = 0
            blueBacking.alpha = 0
        }
        else if (numPlayers == 3){
            nameLabel2.alpha = 1
            nameLabel3.alpha = 1
            nameLabel4.alpha = 0
            nameInput2.alpha = 1
            nameInput3.alpha = 1
            nameInput4.alpha = 0
            greenBacking.alpha = 0.25
            purpleBacking.alpha = 0.25
            blueBacking.alpha = 0
        }
        else if (numPlayers == 4){
            nameLabel2.alpha = 1
            nameLabel3.alpha = 1
            nameLabel4.alpha = 1
            nameInput2.alpha = 1
            nameInput3.alpha = 1
            nameInput4.alpha = 1
            greenBacking.alpha = 0.25
            purpleBacking.alpha = 0.25
            blueBacking.alpha = 0.25
        }
    }
    
    @IBAction func plusButtonPress(_ sender: Any) {
        if (numPlayers<4){
            numPlayers += 1
            numberOfPlayers.text="\(numPlayers) Players"
            changeNumPlayers()
        }
    }
    @IBAction func minusButtonPress(_ sender: Any) {
        if (numPlayers>1){
            numPlayers -= 1
            numberOfPlayers.text="\(numPlayers) Players"
            changeNumPlayers()
            if (numPlayers==1){
                numberOfPlayers.text="\(numPlayers) Player"
            }
        }
    }
    
    //Actually start the game now
    @IBAction func startGame(_ sender: Any) {
        let storyboard = UIStoryboard(name: "GamemodeWar", bundle: nil)
        
        let newViewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerGamemodeWar") as! ViewControllerGamemodeWar
        newViewController.bluetoothEnabled = bluetoothEnabled
        newViewController.playerNames[0] = nameInput1.text!
        newViewController.playerNames[1] = nameInput2.text!
        newViewController.playerNames[2] = nameInput3.text!
        
        
        let screenTransition = ScreenTransitions()
        screenTransition.pushScreen(vc: newViewController, nc: navigationController!)
    }
    
    
    //Variables
    var numPlayers = 1
    var maxPlayers = 4
    var minPlayers = 1
    
    override func viewDidLoad() {
        super.viewDidLoad();
        changeNumPlayers()
        
        activeField = nameInput1
        
        redBacking.layer.cornerRadius = 5
        greenBacking.layer.cornerRadius = 5
        purpleBacking.layer.cornerRadius = 5
        blueBacking.layer.cornerRadius = 5
        
        nameInput1.delegate = self
        nameInput2.delegate = self
        nameInput3.delegate = self
        nameInput4.delegate = self
        
        //Configure random button
        buttonRandom.alpha = 0
        buttonRandom.layer.borderColor = UIColor.white.cgColor;
        buttonRandom.layer.borderWidth = 3;
        buttonRandom.layer.cornerRadius = 3;
        
        //Configure Start Button
        startButton.layer.borderColor = UIColor.white.cgColor;
        startButton.layer.borderWidth = 3;
        startButton.layer.cornerRadius = 3;
        
        //Configure Plus Button
        plusButton.layer.borderColor = UIColor.white.cgColor;
        plusButton.layer.borderWidth = 3;
        plusButton.layer.cornerRadius = 3;
        
        //Configure Minus Button
        minusButton.layer.borderColor = UIColor.white.cgColor;
        minusButton.layer.borderWidth = 3;
        minusButton.layer.cornerRadius = 3;
        
        //Create the stars and purple fade for aesthetic
        let image = UIImage(named: "StarsBackground")
        let imageView = UIImageView(image: image!)
        imageView.frame = self.view.frame
        imageView.layer.zPosition = -100
        view.addSubview(imageView)
        
        let image1 = UIImage(named: "PurpleFadeBackground")?.withRenderingMode(.alwaysTemplate)
        let imageView1 = UIImageView(image: image1!)
        imageView1.tintColor = .purple
        imageView1.frame = self.view.frame
        view.addSubview(imageView1)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    



}
