//
//  Player.swift
//  Modii
//
//  Created by Ikey Benzaken on 7/25/16.
//  Copyright © 2016 Ikey Benzaken. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class Player {
    
    var card: Card!
    var name: String
    var peerID: MCPeerID
    var lives: Int
    var isStillInGame: Bool = true
    
    init(name: String, peerID: MCPeerID) {
        self.name = name
        self.peerID = peerID
        self.lives = 20
    }

}
