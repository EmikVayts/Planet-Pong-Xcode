//
//  UndoTurn.swift
//  Planet Pong
//
//  Created by Mac on 8/11/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import Foundation

class UndoTurn {
    var moveType = ""
    var cupChanged = 0
    
    init(moveType: String, cupChanged: Int) {
        self.moveType = moveType
        self.cupChanged = cupChanged
    }
}
