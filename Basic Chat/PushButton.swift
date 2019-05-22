//
//  PushButton.swift
//  PlanetPongGUI
//
//  Created by Emik Vayts on 4/5/19.
//  Copyright © 2019 Emik Vayts. All rights reserved.
//

import UIKit

@IBDesignable

class PushButton: UIButton {
    
    @IBInspectable var fillColor: UIColor = UIColor.red

    override func draw(_ _rect: CGRect) {
        let path = UIBezierPath(ovalIn: _rect)
        fillColor.setFill()
        path.fill()
    }
    
    func setFillColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        fillColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
        setNeedsDisplay()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
