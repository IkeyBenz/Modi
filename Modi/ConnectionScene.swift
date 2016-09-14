import Foundation
import SpriteKit

class ConnectionScene: SKScene {
    
    
    let startGamebutton = SKLabelNode(fontNamed: "Chalkduster")
    var buttonImage = SKSpriteNode(imageNamed: "Button")
    var textField: UITextField!
    var textFieldStamp = SKLabelNode(fontNamed: "Chalkduster")
    var textFieldImage = SKSpriteNode(imageNamed: "TextField")
    var tableViewImage = SKSpriteNode(imageNamed: "TableViewBorder")
    var yourNameLabel = SKLabelNode(fontNamed: "Chalkduster")
    var waitingForPlayersLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    var peerOne = SKLabelNode(fontNamed: "Chalkduster")
    var peerTwo = SKLabelNode(fontNamed: "Chalkduster")
    var peerThree = SKLabelNode(fontNamed: "Chalkduster")
    var peerFour = SKLabelNode(fontNamed: "Chalkduster")
    var peerFive = SKLabelNode(fontNamed: "Chalkduster")
    var peerSix = SKLabelNode(fontNamed: "Chalkduster")
    var peerSeven = SKLabelNode(fontNamed: "Chalkduster")
    var peerLabels: [SKLabelNode] = []
    
    override func didMove(to view: SKView) {
        
        positionPeerLabels()
        let eightPercentHeight = self.frame.height * 0.07
        var fontSize: CGFloat = 12
        if UIDevice.current.userInterfaceIdiom == .pad {fontSize = 16}
        else if UIDevice.current.userInterfaceIdiom == .phone {fontSize = 12}
        
        let background = SKSpriteNode(imageNamed: "Felt")
        background.size = self.frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = 0
        
        
        yourNameLabel.text = "Your name:"
        yourNameLabel.fontSize = fontSize
        yourNameLabel.position = CGPoint(x: frame.width * 0.15 + (yourNameLabel.frame.width / 2), y: frame.height * 0.87)
        yourNameLabel.zPosition = 10
        
        
        textFieldStamp.text = ""
        textFieldStamp.fontSize = fontSize
        textFieldStamp.position = CGPoint(x: yourNameLabel.frame.maxX + 10 + (textFieldStamp.frame.width / 2), y: yourNameLabel.position.y)
        textFieldStamp.zPosition = 10
        
        
        
        textField = UITextField(frame: CGRect(x: yourNameLabel.frame.maxX + 20, y: frame.height - yourNameLabel.position.y - 25, width: 400, height: 40))
        textField.placeholder = "Type your name here"
        textField.font = UIFont(name: "Chalkduster", size: fontSize)
        textField.textColor = UIColor.white
        textField.delegate = self
        
        textFieldImage.centerRect = CGRect(x: 8.5 / 240, y: 7.5 / 32, width: 223 / 240, height: 17 / 32)
        textFieldImage.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        textFieldImage.position = CGPoint(x: yourNameLabel.frame.maxX + 10, y: yourNameLabel.frame.midY - 2)
        textFieldImage.zPosition = 11
        textFieldImage.xScale = ((frame.width * 0.85) - textFieldImage.frame.minX) / textFieldImage.frame.width
        
    
        
        waitingForPlayersLabel.text = "Type In Your Name Above"
        waitingForPlayersLabel.fontSize = 13
        if UIDevice.current.userInterfaceIdiom == .phone {waitingForPlayersLabel.fontSize = 12}
        else if UIDevice.current.userInterfaceIdiom == .pad {waitingForPlayersLabel.fontSize = 17}
        waitingForPlayersLabel.position = CGPoint(x: frame.width / 2, y: textFieldImage.position.y - (textFieldImage.frame.height / 2) - (waitingForPlayersLabel.frame.height / 2) - eightPercentHeight)
        waitingForPlayersLabel.zPosition = 10
        

        
        startGamebutton.position = CGPoint(x: frame.width / 2, y: frame.maxY / 8)
        startGamebutton.text = "Start Game"
        startGamebutton.fontSize = 18
        startGamebutton.zPosition = 11
        
        buttonImage.position = startGamebutton.position
        buttonImage.zPosition = 10
        buttonImage.centerRect = CGRect(x: 17.0/62.0, y: 17.0/74.0, width: 28.0/62.0, height: 39.0/74.0);
        buttonImage.anchorPoint = CGPoint(x: 0.5, y: 0.3)
        buttonImage.xScale = startGamebutton.frame.width / buttonImage.frame.width + 1
        buttonImage.yScale = startGamebutton.frame.height / buttonImage.frame.height + 0.5
        
        
        tableViewImage.centerRect = CGRect(x: 10 / 458, y: 9 / 150, width: 438 / 458, height: 132 / 150)
        tableViewImage.anchorPoint = CGPoint(x: 0.5, y: 1)
        tableViewImage.position = CGPoint(x: ((frame.width * 0.15) + (tableViewImage.frame.width / 2)), y: waitingForPlayersLabel.frame.minY)
        tableViewImage.xScale = (frame.width * 0.85 - tableViewImage.frame.minX) / tableViewImage.frame.width
        tableViewImage.yScale = (waitingForPlayersLabel.frame.minY - (frame.height * 0.23)) / tableViewImage.frame.height
        tableViewImage.position = CGPoint(x: ((frame.width * 0.15) + (tableViewImage.frame.width / 2)), y: waitingForPlayersLabel.frame.minY)
        tableViewImage.zPosition = 11
        for label in peerLabels {
            label.fontSize = fontSize
            label.fontName = "Chalkduster"
            print(label.yScale)
        }
        
        self.addChild(yourNameLabel)
        self.addChild(textFieldStamp)
        self.addChild(textFieldImage)
        self.addChild(tableViewImage)
        self.addChild(waitingForPlayersLabel)
        self.addChild(background)
        self.addChild(startGamebutton)
        self.addChild(buttonImage)
        view.addSubview(textField)
        
        
    }
    
    func positionPeerLabels() {
        peerLabels = [peerOne, peerTwo, peerThree, peerFour, peerFive, peerSix, peerSeven]
        for label in peerLabels {
            tableViewImage.addChild(label)
            label.fontSize = 14
            label.text = "Not Connected"
        }
        peerOne.position = CGPoint(x: -(tableViewImage.frame.size.width / 4), y: -(tableViewImage.frame.height) + (tableViewImage.frame.size.height / 5 * 4))
        peerTwo.position = CGPoint(x: -(tableViewImage.frame.size.width / 4), y: -(tableViewImage.frame.height) + (tableViewImage.frame.size.height / 5 * 3))
        peerThree.position = CGPoint(x: -(tableViewImage.frame.size.width / 4), y: -(tableViewImage.frame.height) + (tableViewImage.frame.size.height / 5 * 2))
        peerFour.position = CGPoint(x: -(tableViewImage.frame.size.width / 4), y: -(tableViewImage.frame.height) + (tableViewImage.frame.size.height / 5))
        peerFive.position = CGPoint(x: tableViewImage.frame.size.width / 4, y: -(tableViewImage.frame.height) + (tableViewImage.frame.size.height / 5 * 4))
        peerSix.position = CGPoint(x: tableViewImage.frame.size.width / 4, y: -(tableViewImage.frame.height) + (tableViewImage.frame.size.height / 5 * 3))
        peerSeven.position = CGPoint(x: tableViewImage.frame.size.width / 4, y: -(tableViewImage.frame.height) + (tableViewImage.frame.size.height / 5 * 2))
        
        print(tableViewImage.frame.size)
        for label in peerLabels {
            print(label.position)
        }
    }
    
    
    func goToGameScene() {
        let skView = self.view! as SKView
        let scene = GameScene(fileNamed: "GameScene")
        skView.showsFPS = false
        skView.showsNodeCount = false
        scene?.scaleMode = .resizeFill
        skView.presentScene(scene)
        
    }
    
    func orderedPlayersString() -> String {
        GameStateSingleton.sharedInstance.orderedPlayers = []
        let me = GameStateSingleton.sharedInstance.bluetoothService.session.myPeerID
        var orderedPlayers: String = "peerOrder" + me.displayName + "."
        GameStateSingleton.sharedInstance.orderedPlayers.append(Player(name: me.displayName, peerID: me))
        for player in GameStateSingleton.sharedInstance.bluetoothService.session.connectedPeers {
            orderedPlayers += player.displayName + "."
            GameStateSingleton.sharedInstance.orderedPlayers.append(Player(name: player.displayName, peerID: player))
        }
        return orderedPlayers
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if startGamebutton.frame.contains(touch.location(in: self)) {
                buttonImage.texture = SKTexture(imageNamed: "ButtonPressed")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if startGamebutton.frame.contains(touch.location(in: self)) {
                GameStateSingleton.sharedInstance.bluetoothService.sendData(orderedPlayersString())
                GameStateSingleton.sharedInstance.bluetoothService.sendData("currentDealer\(GameStateSingleton.sharedInstance.bluetoothService.session.myPeerID.displayName)")
                GameStateSingleton.sharedInstance.currentDealer = GameStateSingleton.sharedInstance.orderedPlayers[0]
                GameStateSingleton.sharedInstance.bluetoothService.sendData("gametime")
                self.goToGameScene()
            }
            buttonImage.texture = SKTexture(imageNamed: "Button")
        }
    }
    func initializeBluetooth(_ textField: UITextField) {
        if textField.text != nil {
            GameStateSingleton.sharedInstance.deviceName = textField.text!
            textFieldStamp.text = textField.text!
        } else {
            GameStateSingleton.sharedInstance.deviceName = "Missing name"
            textFieldStamp.text = "Missing Name"
        }
        textFieldStamp.position = CGPoint(x: textField.frame.origin.x + (textFieldStamp.frame.width / 2), y: yourNameLabel.position.y - 2)
        textField.resignFirstResponder()
        textField.removeFromSuperview()
        
        let modiService = ModiBlueToothService()
        waitingForPlayersLabel.text = "Waiting For Players..."
        GameStateSingleton.sharedInstance.bluetoothService = modiService
        GameStateSingleton.sharedInstance.bluetoothService.connectionSceneDelegate = self
    }
}

extension ConnectionScene: ConnectionSceneDelegate {
    func connectedDevicesChanged(_ manager: ModiBlueToothService, connectedDevices: [String]) {
        
        for peerLabel in peerLabels {
            peerLabel.text = "Not Connected"
        }
        
        for peerIndex in 0 ..< GameStateSingleton.sharedInstance.bluetoothService.session.connectedPeers.count {
            self.peerLabels[peerIndex].text = GameStateSingleton.sharedInstance.bluetoothService.session.connectedPeers[peerIndex].displayName
        }
        
        GameStateSingleton.sharedInstance.playersDictionary = [:]
        
        let me = GameStateSingleton.sharedInstance.bluetoothService.session.myPeerID
        GameStateSingleton.sharedInstance.playersDictionary[me.displayName] = me
        
        for peer in GameStateSingleton.sharedInstance.bluetoothService.session.connectedPeers {
            GameStateSingleton.sharedInstance.playersDictionary[peer.displayName] = peer
        }
        
        

    }
    func gotoGame() {
        self.goToGameScene()
    }
    func recievedUniversalPeerOrderFromHost(_ peers: [String]) {
        for peer in peers {
            let peerID = GameStateSingleton.sharedInstance.playersDictionary[peer]
            GameStateSingleton.sharedInstance.orderedPlayers.append(Player(name: peer, peerID: peerID!))
        }
    }
}

extension ConnectionScene: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        GameStateSingleton.sharedInstance.bluetoothService = nil
        initializeBluetooth(textField)
        return true
    }
}
