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
    
    // Constraints
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    //actions
    
    @IBAction func randomButton(_ sender: Any){
        if (activeField != nil) {
            let firstName = ["Big", "Yeller", "Yoited"]
            let lastName = ["Mep", "Load", "Jelly", "Nibby", "Kermit", "Marmes"]
            
            let firstNameFinal = firstName.randomElement()
            
            let lastNameFinal = lastName.randomElement()
            
            activeField?.text = "\(firstNameFinal!) \(lastNameFinal!)"
        }
    }
    
    
    @IBAction func startButtonPress(_ sender: Any) {
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        
        lastOffset = self.ScrollView.contentOffset
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constraintContentHeight.constant -= self.keyboardHeight
            
            self.ScrollView.contentOffset = self.lastOffset
        }
        
        keyboardHeight = nil
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
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
        }
    }
    
    func changeNumPlayers(){
        if (numPlayers == 1){
            nameLabel2.isHidden = true
            nameLabel3.isHidden = true
            nameLabel4.isHidden = true
            nameInput2.isHidden = true
            nameInput3.isHidden = true
            nameInput4.isHidden = true
        }
        else if (numPlayers == 2){
            nameLabel2.isHidden = false
            nameLabel3.isHidden = true
            nameLabel4.isHidden = true
            nameInput2.isHidden = false
            nameInput3.isHidden = true
            nameInput4.isHidden = true
        }
        else if (numPlayers == 3){
            nameLabel2.isHidden = false
            nameLabel3.isHidden = false
            nameLabel4.isHidden = true
            nameInput2.isHidden = false
            nameInput3.isHidden = false
            nameInput4.isHidden = true
        }
        else if (numPlayers == 4){
            nameLabel2.isHidden = false
            nameLabel3.isHidden = false
            nameLabel4.isHidden = false
            nameInput2.isHidden = false
            nameInput3.isHidden = false
            nameInput4.isHidden = false
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
    //Variables
    var numPlayers = 1
    var maxPlayers = 4
    var minPlayers = 1
    
    override func viewDidLoad() {
        super.viewDidLoad();
        changeNumPlayers()
        
        nameInput1.delegate = self
        nameInput2.delegate = self
        nameInput3.delegate = self
        nameInput4.delegate = self
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    



}
