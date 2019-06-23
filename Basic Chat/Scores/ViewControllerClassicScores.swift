//
//  ViewControllerClassicScores.swift
//  Planet Pong
//
//  Created by Matthew Vayts on 6/16/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerClassicScores: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    calculateGamesPlayed()
        updateLabels()
    }
    
    var totalGamesPlayed : Float = 100
    var overallAverageStreak : Float = 0
    var averageStreakLastGame : Float = 0
    var bitchCupsLastGame : Int = 0
    var totalBitchCups : Int = 0
    var percentageOfBitchCups : Float = 0
    var totalRingsOfDeath : Int = 0
    var ringsOfDeathLastGame : Int = 0
    var percentageOfRingsOfDeath : Float = 0
    var totalIslands : Int = 0
    var islandsLastGame : Int = 0
    var percentageOfIslands : Float = 0
    
    @IBOutlet weak var totalGamesPlayedLabel: UILabel!
    @IBOutlet weak var averageStreakLabel: UILabel!
    @IBOutlet weak var totalBitchCupsLabel: UILabel!
    @IBOutlet weak var bitchCupsPercentageLabel: UILabel!
    @IBOutlet weak var totalRingsOfDeathLabel: UILabel!
    @IBOutlet weak var ringsOfDeathPercentageLabel: UILabel!
    @IBOutlet weak var totalIslandsLabel: UILabel!
    @IBOutlet weak var islandsPercentageLabel: UILabel!

    func calculateGamesPlayed() {
    totalGamesPlayed += 1
    }
    
    func calculateAverageStreak () {
        
    }
    
   func updateLabels() {
        totalGamesPlayedLabel.text = String(totalGamesPlayed)
    }

    
    
    
    
    
    
    

}
