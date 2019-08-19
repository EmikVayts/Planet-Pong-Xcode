//
//  spaceVibe.swift
//  Planet Pong
//
//  Created by Mac on 8/18/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit

class SpaceVibe: UIViewController {
    
    //Set of UI objects that need to fade out/in when the view is transitioned
    //var animateButtons = [UIButton]()
    //var animateLabels = [UILabel]()
    //var animateImages = [UIImage]()
    
    var timerSpace = Timer()
    
    //Changing variables for environment
    //Things to pass on to another view: starsPosition, starsPosition1, starsAlpha, alphaDir, and imageViewPurple.tintColor
    var starsPosition = 0.0
    var starsPosition1 = 0.0
    var sP1 = 99999.0
    var starsAlpha = 0.5
    var alphaDir = 0 //0 is up, 1 is down
    var purpleColor = UIColor.purple
    
    //Image views for stars and purple fade thingy
    var imageViewStars: UIImageView?
    var imageViewStars1: UIImageView?
    var imageViewPurple: UIImageView?
    
    //X axis constraint for the scrolling space background
    var xAxisConstraint: NSLayoutConstraint?
    var xAxisConstraint1: NSLayoutConstraint?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fadeInAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (sP1 == 99999.0) {
            starsPosition1 = Double(-self.view.frame.size.height)
        } else {
            starsPosition1 = sP1
        }
        
        constrainStars()
    }
    
    func constrainStars() {
        //Create the stars and purple fade for aesthetic
        let image = UIImage(named: "StarsBackground")
        imageViewStars1 = UIImageView(image: image!)
        self.view.addSubview(imageViewStars1!)
        imageViewStars = UIImageView(image: image!)
        self.view.addSubview(imageViewStars!)
        
        imageViewStars?.translatesAutoresizingMaskIntoConstraints = false
        imageViewStars1?.translatesAutoresizingMaskIntoConstraints = false
        //Set the constraint of the stars
        let margins = self.view.layoutMarginsGuide
        imageViewStars!.heightAnchor.constraint(equalTo: margins.heightAnchor).isActive = true
        imageViewStars!.widthAnchor.constraint(equalTo: imageViewStars!.heightAnchor).isActive = true
        xAxisConstraint = imageViewStars!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: CGFloat(starsPosition))
        xAxisConstraint?.isActive = true
        imageViewStars!.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        imageViewStars!.layer.zPosition = -100
        
        imageViewStars1!.heightAnchor.constraint(equalTo: margins.heightAnchor).isActive = true
        imageViewStars1!.widthAnchor.constraint(equalTo: imageViewStars1!.heightAnchor).isActive = true
        imageViewStars1!.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        xAxisConstraint1 = imageViewStars1!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: CGFloat(starsPosition1))
        xAxisConstraint1?.isActive = true
        imageViewStars1!.layer.zPosition = -100
        
        let image1 = UIImage(named: "PurpleFadeBackground")?.withRenderingMode(.alwaysTemplate)
        imageViewPurple = UIImageView(image: image1!)
        imageViewPurple!.tintColor = purpleColor
        imageViewPurple!.frame = self.view.frame
        view.addSubview(imageViewPurple!)
        
        timerSpace = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
    }
    
    //When view is popped, make sure to close out of the timerSpace:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //Only remove timer if being popped, not pushing to a new view
        if (self.isMovingFromParent) {
            timerSpace.invalidate()
        }
    }
    
    func fadeInAnimation() {
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
            self.view.alpha = 1.0
        })
    }
    
    func fadeOutAnimationPush(vc: SpaceVibe) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
            self.view.alpha = 0.0
        }, completion: {
            (finished: Bool) in
            self.pushScreen(vc: vc)
        })
    }
    
    func fadeOutAnimationPop() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
            self.view.alpha = 0.0
        }, completion: {
            (finished: Bool) in
            self.popScreen()
        })
    }
    
    //Push to new view
    func pushScreen (vc: SpaceVibe) {
        //Values to pass on the position of the stars and purple fade
        vc.starsPosition = Double(xAxisConstraint!.constant)
        vc.sP1 = Double(xAxisConstraint1!.constant)
        vc.starsAlpha = starsAlpha
        vc.alphaDir = alphaDir
        vc.purpleColor = imageViewPurple!.tintColor
        
        //Add the fade transition
        let transition = CATransition()
        transition.duration = 0.001
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    //Pop view
    func popScreen () {
        
        //Add the fade transition
        let transition = CATransition()
        transition.duration = 0.001
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.dismiss(animated: false, completion: nil)
        navigationController?.popViewController(animated: false)
    }
    
    //Counter for changing stars and purple fade thingy
    @objc func updateCounter() {
        
        //Scroll the stars
        xAxisConstraint!.constant += 0.5
        xAxisConstraint1!.constant += 0.5
        
        //Loop the stars back to the beggining if they come off of the screen
        if (xAxisConstraint!.constant > self.view.frame.size.height) {
            xAxisConstraint?.constant = -self.view.frame.size.height
        }
        
        if (xAxisConstraint1!.constant > self.view.frame.size.height) {
            xAxisConstraint1?.constant = -self.view.frame.size.height
        }
        
        //For the blending fade animation
        if (alphaDir == 0) {
            starsAlpha += 0.001
            imageViewPurple!.alpha = CGFloat(starsAlpha)
            if (starsAlpha>=1) {
                alphaDir = 1
            }
            
        } else {
            starsAlpha -= 0.001
            imageViewPurple!.alpha = CGFloat(starsAlpha)
            if (starsAlpha<=0.25) {
                alphaDir = 0
                if (imageViewPurple?.tintColor == .green) {
                    imageViewPurple!.tintColor = .purple
                } else if (imageViewPurple?.tintColor == .purple) {
                    imageViewPurple!.tintColor = .blue
                } else if (imageViewPurple?.tintColor == .blue) {
                    imageViewPurple!.tintColor = .red
                } else if (imageViewPurple?.tintColor == .red) {
                    imageViewPurple!.tintColor = .green
                }
            }
        }
    }
}
