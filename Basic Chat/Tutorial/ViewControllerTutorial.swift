//
//  ViewControllerTutorial.swift
//  Planet Pong
//
//  Created by Mac on 6/10/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

//TODO: Andy

import Foundation
import AVKit
import UIKit

class ViewControllerTutorial : UIViewController {

    @IBOutlet weak var videoView: UIView!
    
    //Define a timer & counter for playback of tutorial video
    var timer = Timer()
    var counter = 0 //in ms
    var playing = true
    
    var pausePoints = [22667, 38667, 41000, 42750, 44000, 45500, 47000]
    
    var startPoints = [0, 22733, 38700, 42000, 43000, 44233, 45900]
    
    var currentClip = 0
    
    let videoPreviewLooper = VideoLooperView(clips: VideoClip.allClips())
    
    override func viewWillAppear(_ animated: Bool) {
        
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)

        pausePoints = [22667, 38667, 41000, 42750, 44000, 45500, 47000]
        
        startPoints = [0, 22733, 38700, 42000, 43000, 44233, 45900]
        
        super.viewWillAppear(animated)
        
        videoPreviewLooper.videoPlayerView.frame = videoView.bounds
        
        videoPreviewLooper.videoPlayerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        videoView.addSubview(videoPreviewLooper.videoPlayerView)
        
        videoPreviewLooper.play()
    }
    
    @objc func updateCounter() {
        if (playing==true) {
            counter+=1
            if (counter>=pausePoints[currentClip]) {
                playing=false
                counter=0
                videoPreviewLooper.pause()
            }
        }
    }
    
    @IBAction func pressBack(_ sender: Any) {
        if (currentClip-1<0) {
            playing=true
            counter = startPoints[currentClip]
            videoPreviewLooper.seek(msec: counter)
            videoPreviewLooper.play()
            return
        }
        currentClip-=1
        playing=true
        counter = startPoints[currentClip]
        videoPreviewLooper.seek(msec: counter)
        videoPreviewLooper.play()
    }
    
    @IBAction func hitNext(_ sender: Any) {
        if (currentClip+1>=startPoints.count) {
            playing=true
            counter = startPoints[currentClip]
            videoPreviewLooper.seek(msec: counter)
            videoPreviewLooper.play()
            return
        }
        currentClip+=1
        playing=true
        counter = startPoints[currentClip]
        videoPreviewLooper.seek(msec: counter)
        videoPreviewLooper.play()
    }
    
    @IBAction func hitPlay(_ sender: Any) {
        //Todo - Go to game!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //? Make sure it's paused when the user leaves this screen
        
        print("timer closed out and video paused")
        
        timer.invalidate()
        
        videoPreviewLooper.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
    }
    
}
