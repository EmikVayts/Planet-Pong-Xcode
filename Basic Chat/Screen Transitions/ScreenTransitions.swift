//
//  ScreenPush.swift
//  Planet Pong
//
//  Created by Mac on 8/14/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit

class ScreenTransitions {
    
    //push to a screen with fade transition
    func pushScreen (vc: UIViewController, nc: UINavigationController) {

        //Add the fade transition
        let transition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        
        nc.view.layer.add(transition, forKey: nil)
        
        nc.pushViewController(vc, animated: false)
    }
    
    //pop to the previous screen with fade transition
    func popScreen (nc: UINavigationController) {
        
        //Add the fade transition
        let transition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        
        nc.view.layer.add(transition, forKey: nil)
        nc.dismiss(animated: false, completion: nil)
        nc.popViewController(animated: false)
    }
}
