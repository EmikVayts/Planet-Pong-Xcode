//
//  GaugeView.swift
//  Planet Pong
//
//  Created by Matthew Vayts on 6/25/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

 import Foundation
import UIKit

class GaugeView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let test = GaugeView(frame: CGRect(x: 40, y: 40, width: 256, height: 256))
        test.backgroundColor = .clear
        view.addSubview(test)
    
    var outerBezelColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
    var outerBezelWidth: CGFloat = 10
    
    var innerBezelColor = UIColor.white
    var innerBezelWidth: CGFloat = 5
    
    var insideColor = UIColor.white
    
    func drawBackground(in rect: CGRect, context ctx: CGContext) {
        // draw the outer bezel as the largest circle
        outerBezelColor.set()
        ctx.fillEllipse(in: rect)
        
        // move in a little on each edge, then draw the inner bezel
        let innerBezelRect = rect.insetBy(dx: outerBezelWidth, dy: outerBezelWidth)
        innerBezelColor.set()
        ctx.fillEllipse(in: innerBezelRect)
        
        // finally, move in some more and draw the inside of our gauge
        let insideRect = innerBezelRect.insetBy(dx: innerBezelWidth, dy: innerBezelWidth)
        insideColor.set()
        ctx.fillEllipse(in: insideRect)
    }


}


}
