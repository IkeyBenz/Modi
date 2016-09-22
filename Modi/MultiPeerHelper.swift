import Foundation
import MultipeerConnectivity

protocol ConnectionSceneDelegate {
    func connectedDevicesChanged(_ manager : ModiBlueToothService, connectedDevices: [String])
    func recievedUniversalPeerOrderFromHost(_ peers: [String])
    func gotoGame()
}

protocol GameSceneDelegate {
    func heresTheNewDeck(_ deck: Deck)
    func dealPeersCards()
    func updateLabel(_ str: String)
    func yourTurn()
    func playersTradedCards(_ playerOne: Player, playerTwo: Player)
    func playerTradedWithDeck(_ player: Player)
    func trashCards()
    func endRound()
}


class ModiBlueToothService: NSObject {
    fileprivate let ModiServiceType = "test-service"
    fileprivate var myPeerID: MCPeerID
    fileprivate let serviceAdvertiser: MCNearbyServiceAdvertiser
    fileprivate let serviceBrowser: MCNearbyServiceBrowser
    
    var connectionSceneDelegate: ConnectionSceneDelegate?
    var gameSceneDelegate: GameSceneDelegate?
    
    
    override init() {
        myPeerID = MCPeerID(displayName: GameStateSingleton.sharedInstance.deviceName)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: ModiServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: ModiServiceType)
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    }()
    
    func sendData(_ string: String) {
        if session.connectedPeers.count > 0 {
            var error : NSError?
            do {
                try self.session.send(string.data(using: String.Encoding.utf8, allowLossyConversion: false)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            } catch let error1 as NSError {
                error = error1
                print("%@", "\(error)")
            }
        }
    }

    func peerStringsArray(_ str: String) -> [String] {
        var peerStrings: [String] = []
        var currentPeer: String = ""
        
        for character in str.characters {
            if character != "." {
                currentPeer += String(character)
            } else {
                peerStrings.append(currentPeer)
                currentPeer = ""
            }
        }
        return peerStrings
    }
    
    func handleCardSwapUsingString(_ string: String) {
        var playerOneString: String = ""
        var playerTwoString: String = ""
        var hitPeriod: Bool = false
        var player1: Player!
        var player2: Player!
        
        for character in string.characters {
            if character != "." {
                if !hitPeriod {
                    playerOneString += String(character)
                } else {
                    playerTwoString += String(character)
                }
            } else {
                hitPeriod = true
            }
        }
        
        for player in GameStateSingleton.sharedInstance.orderedPlayers {
            if player.name == playerOneString {
                player1 = player
            } else if player.name == playerTwoString {
                player2 = player
            }
        }
        gameSceneDelegate?.playersTradedCards(player1, playerTwo: player2)
        gameSceneDelegate?.updateLabel("\(player1.name) traded cards with \(player2.name)")
    }
    
}

extension ModiBlueToothService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Did not start advertising peer: \(error)")
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("Did recieve invitation from \(peerID.displayName)")
        
        let isAlreadyPartOfGame: Bool = {
            for player in GameStateSingleton.sharedInstance.orderedPlayers {
                if player.name == peerID.displayName {
                    return true
                }
            }
            return false
        }()
        
        let isntConnected: Bool = {
            for peer in session.connectedPeers {
                if peer.displayName == peerID.displayName {
                    return false
                }
            }
            return true
        }()
        
        if GameStateSingleton.sharedInstance.currentGameState == .waitingForPlayers || (isAlreadyPartOfGame && isntConnected) {
            print("Accepting invitation from \(peerID.displayName)")
            invitationHandler(true, self.session)
        }
    }
}

extension ModiBlueToothService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Did not start browsing for peers: \(error)")
    }
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        
        let isAlreadyPartOfGame: Bool = {
            for player in GameStateSingleton.sharedInstance.orderedPlayers {
                if player.name == peerID.displayName {
                    return true
                }
            }
            return false
        }()
        
        let isntConnected: Bool = {
            for peer in session.connectedPeers {
                if peer.displayName == peerID.displayName {
                    return false
                }
            }
            return true
        }()
        
        if GameStateSingleton.sharedInstance.currentGameState == .waitingForPlayers || (isAlreadyPartOfGame && isntConnected) {
            print("Sending invite to: \(peerID.displayName)")
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 30)
        }
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
    
}

extension MCSessionState {
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "Not Connected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
}

extension ModiBlueToothService: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        
        if str == "gametime" {
            connectionSceneDelegate?.gotoGame()
        }
        if str == "dealCards" {
            gameSceneDelegate?.dealPeersCards()
        }

        if str == "trash" {
            gameSceneDelegate?.trashCards()
        }
        
        if str == "endRound" {
            gameSceneDelegate?.endRound()
        }
        
        
        if str.characters.count > 9 {
            if str.substring(to: str.characters.index(str.startIndex, offsetBy: 10)) == "deckString" {
                let deckString = str.replacingOccurrences(of: "deckString", with: "")
                gameSceneDelegate?.heresTheNewDeck(Deck(withString: deckString))
            }
            
            if str.substring(to: str.characters.index(str.startIndex, offsetBy: 10)) == "nextDealer" {
                let dealerName = str.replacingOccurrences(of: "nextDealer", with: "")
                for player in GameStateSingleton.sharedInstance.orderedPlayers {
                    if player.name == dealerName {
                        GameStateSingleton.sharedInstance.currentDealer = player
                    }
                }
                
            }
            
            if str.substring(to: str.characters.index(str.startIndex, offsetBy: 9)) == "peerOrder" {
                let peerOrder = str.replacingOccurrences(of: "peerOrder", with: "")
                connectionSceneDelegate?.recievedUniversalPeerOrderFromHost(peerStringsArray(peerOrder))
            }
            
            if str.substring(to: str.characters.index(str.startIndex, offsetBy: 11)) == "updateLabel" {
                let updateString = str.replacingOccurrences(of: "updateLabel", with: "")
                gameSceneDelegate?.updateLabel(updateString)
            }
            
            if str.substring(to: str.characters.index(str.startIndex, offsetBy: 11)) == "playersTurn" {
                let player = str.replacingOccurrences(of: "playersTurn", with: "")
                if player == self.session.myPeerID.displayName {
                    gameSceneDelegate?.yourTurn()
                }
            }
            
            if str.substring(to: str.characters.index(str.startIndex, offsetBy: 11)) == "hittingDeck" {
                let string = str.replacingOccurrences(of: "hittingDeck", with: "")
                for player in GameStateSingleton.sharedInstance.orderedPlayers {
                    if string == player.name {
                        gameSceneDelegate?.playerTradedWithDeck(player)
                    }
                }
            }
            
            if str.substring(to: str.characters.index(str.startIndex, offsetBy: 12)) == "playerTraded" {
                let string = str.replacingOccurrences(of: "playerTraded", with: "")
                self.handleCardSwapUsingString(string)
            }
            
            if str.substring(to: str.characters.index(str.startIndex, offsetBy: 13)) == "currentDealer" {
                let currentDealerName = str.replacingOccurrences(of: "currentDealer", with: "")
                for player in GameStateSingleton.sharedInstance.orderedPlayers {
                    if player.name == currentDealerName {
                        GameStateSingleton.sharedInstance.currentDealer = player
                    }
                }
            }
        }
        
        
    }
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("\(peerID.displayName) did change state: \(state.stringValue())")
        if state == .notConnected {
            serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 30)
        }
        self.connectionSceneDelegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
        if GameStateSingleton.sharedInstance.currentGameState == .waitingForPlayers {
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
}
