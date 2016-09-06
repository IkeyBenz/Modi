import Foundation
import MultipeerConnectivity

protocol ConnectionSceneDelegate {
    func connectedDevicesChanged(manager : ModiBlueToothService, connectedDevices: [String])
    func recievedUniversalPeerOrderFromHost(peers: [String])
    func gotoGame()
}

protocol GameSceneDelegate {
    func heresTheNewDeck(deck: Deck)
    func dealPeersCards()
    func updateLabel(str: String)
    func yourTurn()
    func playersTradedCards(playerOne: Player, playerTwo: Player)
    func playerTradedWithDeck(player: Player)
    func trashCards()
    func endRound()
}


class ModiBlueToothService: NSObject {
    private let ModiServiceType = "modii-service"
    private var myPeerID: MCPeerID
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
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
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    
    func sendData(string: String) {
        if session.connectedPeers.count > 0 {
            var error : NSError?
            do {
                try self.session.sendData(string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error1 as NSError {
                error = error1
                print("%@", "\(error)")
            }
        }
    }

    func peerStringsArray(str: String) -> [String] {
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
    
    func handleCardSwapUsingString(string: String) {
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
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("Did not start advertising peer: \(error)")
    }
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        
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
        
        if GameStateSingleton.sharedInstance.currentGameState == .WaitingForPlayers || (isAlreadyPartOfGame && isntConnected) {
            print("Accepting invitation from \(peerID.displayName)")
            invitationHandler(true, self.session)
        }
    }
}

extension ModiBlueToothService: MCNearbyServiceBrowserDelegate {
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("Did not start browsing for peers: \(error)")
    }
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
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
        
        if GameStateSingleton.sharedInstance.currentGameState == .WaitingForPlayers || (isAlreadyPartOfGame && isntConnected) {
            print("Sending invite to: \(peerID.displayName)")
            browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 30)
        }
    }
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
    
}

extension MCSessionState {
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "Not Connected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
}

extension ModiBlueToothService: MCSessionDelegate {
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        
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
            if str.substringToIndex(str.startIndex.advancedBy(10)) == "deckString" {
                let deckString = str.stringByReplacingOccurrencesOfString("deckString", withString: "")
                gameSceneDelegate?.heresTheNewDeck(Deck(withString: deckString))
            }
            
            if str.substringToIndex(str.startIndex.advancedBy(10)) == "nextDealer" {
                let dealerName = str.stringByReplacingOccurrencesOfString("nextDealer", withString: "")
                for player in GameStateSingleton.sharedInstance.orderedPlayers {
                    if player.name == dealerName {
                        GameStateSingleton.sharedInstance.currentDealer = player
                    }
                }
                
            }
            
            if str.substringToIndex(str.startIndex.advancedBy(9)) == "peerOrder" {
                let peerOrder = str.stringByReplacingOccurrencesOfString("peerOrder", withString: "")
                connectionSceneDelegate?.recievedUniversalPeerOrderFromHost(peerStringsArray(peerOrder))
            }
            
            if str.substringToIndex(str.startIndex.advancedBy(11)) == "updateLabel" {
                let updateString = str.stringByReplacingOccurrencesOfString("updateLabel", withString: "")
                gameSceneDelegate?.updateLabel(updateString)
            }
            
            if str.substringToIndex(str.startIndex.advancedBy(11)) == "playersTurn" {
                let player = str.stringByReplacingOccurrencesOfString("playersTurn", withString: "")
                if player == self.session.myPeerID.displayName {
                    gameSceneDelegate?.yourTurn()
                }
            }
            
            if str.substringToIndex(str.startIndex.advancedBy(11)) == "hittingDeck" {
                let string = str.stringByReplacingOccurrencesOfString("hittingDeck", withString: "")
                for player in GameStateSingleton.sharedInstance.orderedPlayers {
                    if string == player.name {
                        gameSceneDelegate?.playerTradedWithDeck(player)
                    }
                }
            }
            
            if str.substringToIndex(str.startIndex.advancedBy(12)) == "playerTraded" {
                let string = str.stringByReplacingOccurrencesOfString("playerTraded", withString: "")
                self.handleCardSwapUsingString(string)
            }
            
            if str.substringToIndex(str.startIndex.advancedBy(13)) == "currentDealer" {
                let currentDealerName = str.stringByReplacingOccurrencesOfString("currentDealer", withString: "")
                for player in GameStateSingleton.sharedInstance.orderedPlayers {
                    if player.name == currentDealerName {
                        GameStateSingleton.sharedInstance.currentDealer = player
                    }
                }
            }
        }
        
        
    }
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("\(peerID.displayName) did change state: \(state.stringValue())")
        if state == .NotConnected {
            serviceBrowser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 30)
        }
        self.connectionSceneDelegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
        if GameStateSingleton.sharedInstance.currentGameState == .WaitingForPlayers {
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
}