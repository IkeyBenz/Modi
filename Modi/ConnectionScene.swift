import Foundation
import SpriteKit

class ConnectionScene: SKScene {
    
    let globalFont: String = "Chalkboard SE"
    let startGamebutton = SKLabelNode(fontNamed: "Chalkboard SE")
    var buttonImage = SKSpriteNode(imageNamed: "Button")
    var textField: UITextField!
    var textFieldStamp = SKLabelNode(fontNamed: "Chalkboard SE")
    var textFieldImage = SKSpriteNode(imageNamed: "TextField")
    var tableViewImage = SKSpriteNode(imageNamed: "TextField")
    var yourNameLabel = SKLabelNode(fontNamed: "Chalkboard SE")
    var waitingForPlayersLabel = SKLabelNode(fontNamed: "Chalkboard SE")
    var fontSize: CGFloat = 12
    var instructions = SKSpriteNode(imageNamed: "Felt")
    var instructionsButton = SKSpriteNode(imageNamed: "QuestionMark")
    var instructionsLabel: UILabel!
    
    var peerOne = SKLabelNode()
    var peerTwo = SKLabelNode()
    var peerThree = SKLabelNode()
    var peerFour = SKLabelNode()
    var peerFive = SKLabelNode()
    var peerSix = SKLabelNode()
    var peerSeven = SKLabelNode()
    var peerLabels: [SKLabelNode] = []
    
    override func didMove(to view: SKView) {
        
        
        let eightPercentHeight = self.frame.height * 0.07
        
        if UIDevice.current.userInterfaceIdiom == .pad {fontSize = 16}
        else if UIDevice.current.userInterfaceIdiom == .phone {fontSize = 12}
        
        //instructions = SKSpriteNode(color: UIColor.black, size: self.size)
        instructions.size = self.frame.size
        instructions.position = CGPoint(x: self.frame.maxX / 2, y: self.frame.maxY / 2)
        instructions.alpha = 0.9
        instructions.zPosition = 75
        instructions.isHidden = true
        self.addChild(instructions)
        
        instructionsLabel = UILabel(frame: self.frame)
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = UIColor.white
        instructionsLabel.font = UIFont(name: "Chalkboard SE", size: fontSize + 5)
        instructionsLabel.text = "Connect Over A Wifi Network: \n\t- Turn wifi ON for ALL devices\n\t- Make sure all devices are connected to\n\t  the same wifi network\n\nConnect Without A Wifi Network:\n\t- Turn wifi ON for ALL devices\n\t- Every device must be disconnected from\n\t  any nearby wifi networks"
        
        instructionsLabel.frame.origin = CGPoint(x: self.frame.maxX * 0.15, y: 0)
        
        instructionsButton.xScale = 1.2
        instructionsButton.yScale = 1.2
        instructionsButton.position = CGPoint(x: self.frame.maxX - (instructionsButton.frame.width / 2) - 5, y: self.frame.maxY - (instructionsButton.frame.height / 2) - 5)
        instructionsButton.zPosition = 80
        self.addChild(instructionsButton)
        
        
        
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
        
        
        textFieldImage.centerRect = CGRect(x: 8.5 / 240, y: 7.5 / 32, width: 223 / 240, height: 17 / 32)
        textFieldImage.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        textFieldImage.position = CGPoint(x: yourNameLabel.frame.maxX + 10, y: yourNameLabel.frame.midY)
        textFieldImage.zPosition = 11
        
        

        textField = UITextField(frame: CGRect(x: yourNameLabel.frame.maxX + 20, y: frame.height - yourNameLabel.position.y - 22, width: 400, height: 40))
        textField.frame.size = textFieldImage.frame.size
        textField.placeholder = "Type your name here"
        textField.font = UIFont(name: "Chalkboard SE", size: fontSize)
        textField.textColor = UIColor.white
        textField.delegate = self
        textField.text = nil
        textFieldImage.xScale = ((frame.width * 0.85) - textFieldImage.frame.minX) / textFieldImage.frame.width
        
        
        
        waitingForPlayersLabel.text = "Type In Your Name Above"
        waitingForPlayersLabel.fontSize = 16
        waitingForPlayersLabel.position = CGPoint(x: frame.width / 2, y: textFieldImage.position.y - (textFieldImage.frame.height / 2) - (waitingForPlayersLabel.frame.height / 2) - eightPercentHeight)
        waitingForPlayersLabel.zPosition = 10
        

        
        startGamebutton.position = CGPoint(x: frame.width / 2, y: frame.maxY / 8)
        startGamebutton.text = "Start Game"
        startGamebutton.fontSize = 18
        startGamebutton.zPosition = 11
        
        
        if UIDevice.current.userInterfaceIdiom == .phone {waitingForPlayersLabel.fontSize = 14; self.fontSize = 14; yourNameLabel.fontSize = 12; textField.minimumFontSize = 12; textFieldStamp.fontSize = 12}
        else if UIDevice.current.userInterfaceIdiom == .pad {waitingForPlayersLabel.fontSize = 20; self.fontSize = 30; yourNameLabel.fontSize = 18; textField.minimumFontSize = 18; textFieldStamp.fontSize = 18; startGamebutton.fontSize = 35}

        
        buttonImage.zPosition = 10
        buttonImage.centerRect = CGRect(x: 17.0/62.0, y: 17.0/74.0, width: 28.0/62.0, height: 39.0/74.0)
        buttonImage.anchorPoint = CGPoint(x: 0.5, y: 0.3)
        buttonImage.xScale = startGamebutton.frame.width / buttonImage.frame.width + 1
        buttonImage.yScale = startGamebutton.frame.height / buttonImage.frame.height + 0.5
        buttonImage.position = CGPoint(x: startGamebutton.position.x, y: startGamebutton.position.y + 2)
        
        
        
        tableViewImage.centerRect = CGRect(x: 8.5 / 240, y: 7.5 / 32, width: 223 / 240, height: 17 / 32)
        tableViewImage.anchorPoint = CGPoint(x: 0.5, y: 1)
        tableViewImage.position = CGPoint(x: ((frame.width * 0.15) + (tableViewImage.frame.width / 2)), y: waitingForPlayersLabel.frame.minY)
        tableViewImage.xScale = (frame.width * 0.85 - tableViewImage.frame.minX) / tableViewImage.frame.width
        tableViewImage.yScale = (waitingForPlayersLabel.frame.minY - (frame.height * 0.23)) / tableViewImage.frame.height
        tableViewImage.position = CGPoint(x: ((frame.width * 0.15) + (tableViewImage.frame.width / 2)), y: waitingForPlayersLabel.frame.minY)
        tableViewImage.zPosition = 11
        positionPeerLabels()
        
        
        
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
            self.addChild(label)
            label.text = "Not Connected"
            label.fontName = globalFont
            label.fontSize = self.fontSize
            label.zPosition = 2
        }
        peerOne.position = CGPoint(x: tableViewImage.position.x - (tableViewImage.frame.size.width / 4), y: tableViewImage.position.y + (tableViewImage.frame.size.height * 0.3) - (tableViewImage.frame.size.height / 2))
        peerTwo.position = CGPoint(x: tableViewImage.position.x - (tableViewImage.frame.size.width / 4), y: tableViewImage.position.y + (tableViewImage.frame.size.height * 0.1) - (tableViewImage.frame.size.height / 2))
        peerThree.position = CGPoint(x: tableViewImage.position.x - (tableViewImage.frame.size.width / 4), y: tableViewImage.position.y - (tableViewImage.frame.size.height * 0.1) - (tableViewImage.frame.size.height / 2))
        peerFour.position = CGPoint(x: tableViewImage.position.x - (tableViewImage.frame.size.width / 4), y: tableViewImage.position.y - (tableViewImage.frame.size.height * 0.3) - (tableViewImage.frame.size.height / 2))
        peerFive.position = CGPoint(x: tableViewImage.position.x + (tableViewImage.frame.size.width / 4), y: tableViewImage.position.y + (tableViewImage.frame.size.height * 0.3) - (tableViewImage.frame.size.height / 2))
        peerSix.position = CGPoint(x: tableViewImage.position.x + (tableViewImage.frame.size.width / 4), y: tableViewImage.position.y + (tableViewImage.frame.size.height * 0.1) - (tableViewImage.frame.size.height / 2))
        peerSeven.position = CGPoint(x: tableViewImage.position.x + (tableViewImage.frame.size.width / 4), y: tableViewImage.position.y - (tableViewImage.frame.size.height * 0.1) - (tableViewImage.frame.size.height / 2))
        
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
            if buttonImage.frame.contains(touch.location(in: self)) {
                if textFieldStamp.text == "" {
                    let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.15)
                    let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 0.15)
                    waitingForPlayersLabel.run(SKAction.sequence([moveUp, moveDown]))
                } else {
                    buttonImage.texture = SKTexture(imageNamed: "ButtonPressed")
                }
            }
            if instructionsButton.frame.contains(touch.location(in: self)) {
                if instructions.isHidden {
                    instructions.isHidden = false
                    self.view?.addSubview(instructionsLabel)
                    instructionsButton.texture = SKTexture(imageNamed: "ExitButton")
                } else if !instructions.isHidden {
                    instructions.isHidden = true
                    instructionsLabel.removeFromSuperview()
                    instructionsButton.texture = SKTexture(imageNamed: "QuestionMark")
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if startGamebutton.frame.contains(touch.location(in: self)) {
                if textFieldStamp.text != "" {
                    GameStateSingleton.sharedInstance.bluetoothService.sendData(orderedPlayersString(), messageType: "playerOrderString")
                    GameStateSingleton.sharedInstance.bluetoothService.sendData("currentDealer\(GameStateSingleton.sharedInstance.bluetoothService.session.myPeerID.displayName)", messageType: "currentDealer")
                    GameStateSingleton.sharedInstance.currentDealer = GameStateSingleton.sharedInstance.orderedPlayers[0]
                    GameStateSingleton.sharedInstance.bluetoothService.sendData("gametime", messageType: "gametime")
                    self.goToGameScene()
                }
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
        textFieldStamp.position = CGPoint(x: textField.frame.origin.x + (textFieldStamp.frame.width / 2), y: yourNameLabel.position.y)
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
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != nil && textField.text != "" {
            GameStateSingleton.sharedInstance.bluetoothService = nil
            initializeBluetooth(textField)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != nil && textField.text != "" {
            textField.resignFirstResponder()
        }
        return true
    }
}
