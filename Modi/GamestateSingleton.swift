import Foundation
import MultipeerConnectivity


class GameStateSingleton {
    
    class var sharedInstance: GameStateSingleton {
        struct Static {
            static let instance: GameStateSingleton = GameStateSingleton()
        }
        return Static.instance
    }
    
    
    enum GameState {
        case waitingForPlayers
        case inSession
        case gameOver
    }
    
    var gameLoaded: Bool = false
    var currentGameState: GameState = .waitingForPlayers
    var bluetoothService: ModiBlueToothService!
    var bluetoothServiceName: String! {
        didSet {
            var replacementString: String = ""
            for character in bluetoothServiceName.characters {
                if character != " " {
                    replacementString += String(character)
                }
            }
            bluetoothServiceName = replacementString
        }
    }
    var deviceName: String = ""
    var orderedPlayers: [Player] = []
    var playersDictionary: [String : MCPeerID] = [:]
    var myPlayer: Player!
    var currentDealer: Player!
    var playersStillInGame: [Player] = []
    
    func reset() {
        gameLoaded = false
        currentGameState = .waitingForPlayers
        bluetoothService = nil
        bluetoothServiceName = ""
        deviceName = ""
        orderedPlayers = []
        playersDictionary = [:]
        myPlayer = nil
        currentDealer = nil
        playersStillInGame = []
    }
    
}
