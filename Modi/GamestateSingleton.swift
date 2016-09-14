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
    
    var currentGameState: GameState = .waitingForPlayers
    var bluetoothService: ModiBlueToothService!
    var deviceName: String = ""
    var orderedPlayers: [Player] = []
    var playersDictionary: [String: MCPeerID] = [:]
    var myPlayer: Player!
    var currentDealer: Player!
    
    
}
