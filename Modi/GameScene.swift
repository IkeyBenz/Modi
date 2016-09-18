//
//  GameScene.swift
//  Modii
//
//  Created by Ikey Benzaken on 7/17/16.
//  Copyright (c) 2016 Ikey Benzaken. All rights reserved.
//

import SpriteKit

//  NEXT MOVE:
//  - DISABLE TRADING WITH KINGS
//  - IF PLAYER IS FIRST IN ORDER (IF PLAYER IS THE DEALER) HE SWITCHES WITH THE DECK AND THE ROUND ENDS
//  - LET THAT RUN IN AN ENDLESS LOOP UNTIL ONLY ONE LIFE REMAINS


// FIX THE ENDOFROUND FUNCTION
// YOU CALLED IT NINE DIFFERENT TIMES, FUCKHEAD.

class GameScene: SKScene {
    
    let GS = GameStateSingleton.sharedInstance
    var deck = Deck()
    var players: Int = GameStateSingleton.sharedInstance.orderedPlayers.count
    var cardsInPlay: [Card] = []
    var cardsInTrash: [Card] = []
    let dealButton = SKLabelNode(fontNamed: "Chalkboard SE")
    var dealButtonImage = SKSpriteNode(imageNamed: "Button")
    var deckOfCards: [Card] = []
    var trashDeck = Deck()
    var tradeButton = SKLabelNode(fontNamed: "Chalkboard SE")
    var tradeButtonImage = SKSpriteNode(imageNamed: "Button")
    let endGameButton = SKLabelNode(fontNamed: "Chalkboard SE")
    var stickButton = SKLabelNode(fontNamed: "Chalkboard SE")
    var stickButtonImage = SKSpriteNode(imageNamed: "Button")
    var updateLabel = SKLabelNode(fontNamed: "Chalkboard SE")
    var roundLabel = SKLabelNode(fontNamed: "Chalkboard SE")
    var roundNumber: Int = 0
    var myTurnToDeal: Bool = false
    var deckPosition = CGPoint(x: 0, y: 0)
    var trashPosition = CGPoint(x: 0, y: 0)
    var playerLabels: [SKLabelNode] = []
    var playerLabelsInLeaderBoard: [SKLabelNode] = []
    var leaderBoardComponenets: [SKSpriteNode] = []
    var playersInOrderOfLives: [Player] = []
    var playersStillInTheGame: [Player] = []
    var itsTheEndOfTheGame: Bool = false
    var losers: [Player] = []
    var blackBackground: SKSpriteNode!
    
    
    
    let playerIndexOrder: Int = {
        let index: Int = 0
        for x in 0 ..< GameStateSingleton.sharedInstance.orderedPlayers.count {
            if GameStateSingleton.sharedInstance.orderedPlayers[x].peerID == GameStateSingleton.sharedInstance.bluetoothService.session.myPeerID {
                print(x + 1)
                return x + 1
            }
        }
        return index
    }()
    
    let myPlayer: Player = {
        for player in GameStateSingleton.sharedInstance.orderedPlayers {
            if player.peerID == GameStateSingleton.sharedInstance.bluetoothService.session.myPeerID {
                GameStateSingleton.sharedInstance.myPlayer = player
                return player
            }
        }
        return Player(name: GameStateSingleton.sharedInstance.bluetoothService.session.myPeerID.displayName, peerID: GameStateSingleton.sharedInstance.bluetoothService.session.myPeerID)
    }()
    
    
    
    override func didMove(to view: SKView) {
        
        GS.bluetoothService.gameSceneDelegate = self
        GS.currentGameState = .inSession
        playersInOrderOfLives = GS.orderedPlayers
        playersStillInTheGame = GS.orderedPlayers
        
        setUpLeaderBoard()
        self.trashDeck.cards = []
        
        
        let background = SKSpriteNode(imageNamed: "Felt")
        background.size = self.frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        
        
        //let threePercentWidth = self.frame.maxX * 0.03
        
        let referenceCard = Card(suit: "spades", readableRank: "Ace", rank: 1)
        referenceCard.size = resizeCard(referenceCard)
        
        
        trashPosition.x = self.frame.width - (referenceCard.frame.width)
        deckPosition.x = trashPosition.x - (referenceCard.frame.width * 1.6)
        
        dealButton.fontSize = 24
        dealButton.text = "Deal Cards"
        dealButton.position = CGPoint(x: (trashPosition.x + deckPosition.x) / 2, y: self.frame.maxY / 14)
        dealButton.zPosition = 1
        setupButton(dealButtonImage, buttonLabel: dealButton)
        
        trashPosition.y = dealButton.position.y + dealButtonImage.size.height + (referenceCard.size.height / 2)
        deckPosition.y = trashPosition.y
        
        
        if GS.currentDealer.peerID == myPlayer.peerID {
            deck.shuffle()
            GS.bluetoothService.sendData("deckString" + deck.cardsString)
            placeDeckOnScreen()
        }
        
        tradeButton.text = "Swap"
        stickButton.text = "Stick"
        tradeButton.fontSize = 24
        stickButton.fontSize = 24
        tradeButton.position = CGPoint(x: frame.maxX * 0.68, y: frame.maxY * 0.7)
        stickButton.position = CGPoint(x: tradeButton.frame.maxX + (stickButton.frame.width / 1.25), y: tradeButton.position.y)
        tradeButton.zPosition = 1.0
        stickButton.zPosition = 1.0
        setupButton(tradeButtonImage, buttonLabel: tradeButton)
        setupButton(stickButtonImage, buttonLabel: stickButton)
        
        roundLabel.text = "Round 1"
        roundLabel.position = CGPoint(x: frame.maxX / 2, y: frame.maxY / 2)
        roundLabel.fontSize = 24
        roundLabel.zPosition = 1
        
        updateLabel.text = "Loading Game..."
        updateLabel.position = CGPoint(x: frame.maxX * 0.75, y: frame.maxY - 25)
        updateLabel.zPosition = 1
        updateLabel.fontSize = 14
        
        
        self.addChild(background)
        self.addChild(updateLabel)
        runBeginingOfRoundFunctions()
        
        //END OF GAME VIEW
        blackBackground = SKSpriteNode(color: UIColor.black, size: background.size)
        blackBackground.alpha = 0.0
        blackBackground.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        blackBackground.zPosition = 100
        self.addChild(blackBackground)
        
        let winnerLabel = SKLabelNode(text: "Winner: ")
        winnerLabel.fontName = "Chalkboard SE"
        winnerLabel.position = CGPoint(x: 0, y: blackBackground.frame.height * 0.75 - (blackBackground.frame.height / 2))
        winnerLabel.zPosition = 1
        winnerLabel.fontSize = 24
        winnerLabel.name = "winnerLabel"
        
        let loserLabel = SKLabelNode(text: "Losers: ")
        loserLabel.fontName = "Chalkboard SE"
        loserLabel.position = CGPoint(x: 0, y: blackBackground.frame.height * 0.45 - (blackBackground.frame.height / 2))
        loserLabel.zPosition = 1
        loserLabel.fontSize = 24
        loserLabel.name = "loserLabel"
        
        endGameButton.position = CGPoint(x: 0, y: blackBackground.frame.height / 5 - (blackBackground.frame.height / 2))
        endGameButton.zPosition = 1
        endGameButton.fontSize = 18
        endGameButton.text = "End Game"
        let endGameButtonImage = SKSpriteNode(imageNamed: "Button")
        blackBackground.addChild(endGameButton)
        blackBackground.addChild(endGameButtonImage)
        setupButton(endGameButtonImage, buttonLabel: endGameButton)
        
        blackBackground.addChild(winnerLabel)
        blackBackground.addChild(loserLabel)
        
        print(winnerLabel.position)
        print(loserLabel.position)
        
        

        
    }
    
    func setUpLeaderBoard() {
        let leaderBoardBorder = SKSpriteNode(imageNamed: "Button")
        leaderBoardBorder.centerRect = CGRect(x: 17.0/62.0, y: 17.0/74.0, width: 28.0/62.0, height: 39.0/74.0)
        leaderBoardBorder.xScale = (self.frame.width / 4) / leaderBoardBorder.frame.width
        leaderBoardBorder.yScale = (SKSpriteNode(imageNamed: "CellBackground").frame.height * CGFloat(players + 1)) / leaderBoardBorder.frame.height
        leaderBoardBorder.position = CGPoint(x: self.frame.width / 4, y: self.frame.height / 2)
        leaderBoardBorder.zPosition = 11
        self.addChild(leaderBoardBorder)
        leaderBoardComponenets.append(leaderBoardBorder)
        
        var playerAtLiveCount: [String : Int] = [:]
        for player in GS.orderedPlayers {
            playerAtLiveCount[player.name] = player.lives
        }
        
        playersInOrderOfLives = {
            var playerOrder: [Player] = []
            
            let playersLivesInOrder: [Int] = {
                var lives: [Int] = []
                for player in GS.orderedPlayers {
                    lives.append(player.lives)
                }
                print("Lives in order: \(lives.sorted(by: >))")
                return lives.sorted(by: >)
            }()
            
            let livesWODuplicates: [Int] = {
                var arr: [Int] = []
                for number in playersLivesInOrder {
                    if !arr.contains(number) {
                        arr.append(number)
                    }
                }
                return arr
            }()
            for life in livesWODuplicates {
                for x in 0 ..< GS.orderedPlayers.count {
                    if GS.orderedPlayers[x].lives == life {
                        playerOrder.append(GS.orderedPlayers[x])
                    }
                }
            }
            return playerOrder
        }()
        
        
        for x in 0 ..< playersInOrderOfLives.count {
            let cellView = SKSpriteNode(imageNamed: "CellBackground")
            let playerLabel = SKLabelNode(fontNamed: "Chalkboard SE")
            let fadeLabel = SKAction.fadeOut(withDuration: 3)
            let removeLabel = SKAction.run({playerLabel.removeFromParent()})
            playerLabel.text = "\(x + 1)) \(playersInOrderOfLives[x].name): \(playersInOrderOfLives[x].lives) lives"
            playerLabel.zPosition = 11
            playerLabel.fontSize = 12
            cellView.xScale = (leaderBoardBorder.frame.width * 0.85) / cellView.frame.width
            cellView.position = CGPoint(x: leaderBoardBorder.position.x, y: leaderBoardBorder.frame.maxY - (CGFloat(x) * cellView.frame.height))
            playerLabel.position = CGPoint(x: cellView.position.x, y: cellView.position.y - (cellView.frame.height / 1.5))
            cellView.anchorPoint = CGPoint(x: 0.5, y: 1)
            cellView.zPosition = 11
            self.addChild(cellView)
            self.addChild(playerLabel)
            if playersInOrderOfLives[x].lives == 0 {
                
                playerLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run({playerLabel.fontColor = UIColor.red})]))
                playerLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1), fadeLabel]))
                self.run(SKAction.sequence([SKAction.wait(forDuration: 3), removeLabel]))
                for player in GS.orderedPlayers {
                    if playersInOrderOfLives[x].name == player.name {
                        losers.append(player)
                    }
                }
            }
            leaderBoardComponenets.append(cellView)
            playerLabelsInLeaderBoard.append(playerLabel)
        }
    }
    
    func removeLeaderBoard() {
        for sprite in leaderBoardComponenets {
            sprite.removeFromParent()
        }
        for label in playerLabelsInLeaderBoard {
            label.removeFromParent()
        }
    }
    
    func setupButton(_ buttonImage: SKSpriteNode, buttonLabel: SKLabelNode) {
        buttonImage.position = buttonLabel.position
        buttonImage.zPosition = buttonLabel.zPosition - 0.1
        buttonImage.centerRect = CGRect(x: 17.0/62.0, y: 17.0/74.0, width: 28.0/62.0, height: 39.0/74.0);
        buttonImage.anchorPoint = CGPoint(x: 0.5, y: 0.25)
        buttonImage.xScale = buttonLabel.frame.width / buttonImage.frame.width + 0.5
        buttonImage.yScale = buttonLabel.frame.height / buttonImage.frame.height + 0.5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let wait = SKAction.wait(forDuration: 2)
        let block = SKAction.run({self.nextPlayerGoes()})
        let endMyTurn = SKAction.sequence([wait, block])
        for touch in touches {
            
            if atPoint(touch.location(in: self)) == dealButton {
                dealCards()
                GS.bluetoothService.sendData("dealCards")
                dealButton.removeFromParent()
                dealButtonImage.removeFromParent()
                self.run(endMyTurn)
            }
            if atPoint(touch.location(in: self)) == stickButton {
                GS.bluetoothService.sendData("updateLabel\(myPlayer.name) stuck")
                self.updateLabel.text = "\(myPlayer.name) stuck"
                if myPlayer.peerID == GS.currentDealer.peerID {
                    self.runEndOfRoundFunctions()
                    GS.bluetoothService.sendData("endRound")
                } else {
                    self.run(endMyTurn)
                }
                self.removePlayerOptions()
            }
            if atPoint(touch.location(in: self)) == tradeButton {
                if myPlayer.peerID != GS.currentDealer.peerID {
                    if myPlayer.card.readableRank == "King" || playersStillInTheGame[loopableIndex(playerIndexOrder, range: playersStillInTheGame.count)].card.readableRank == "King" {
                        if myPlayer.card.readableRank == "King" {
                            self.updateLabel.text = "You can't trade your king!"
                            GS.bluetoothService.sendData("updateLabel\(myPlayer.name) stuck")
                            self.run(endMyTurn)
                        }
                        if playersStillInTheGame[loopableIndex(playerIndexOrder, range: playersStillInTheGame.count)].card.readableRank == "King" {
                            self.updateLabel.text = "\(playersStillInTheGame[loopableIndex(playerIndexOrder, range: playersStillInTheGame.count)].name) has a king!"
                            GS.bluetoothService.sendData("updateLabel\(myPlayer.name) tried to swap with \(playersStillInTheGame[loopableIndex(playerIndexOrder, range: playersStillInTheGame.count)].name)")
                            self.run(endMyTurn)
                        }
                    } else {
                        self.tradeCardWithPlayer(myPlayer, playerTwo: playersStillInTheGame[loopableIndex(playerIndexOrder, range: playersStillInTheGame.count)])
                        GS.bluetoothService.sendData("playerTraded\(myPlayer.name).\(playersStillInTheGame[loopableIndex(playerIndexOrder, range: playersStillInTheGame.count)].name)")
                        self.updateLabel.text = "\(myPlayer.name) traded cards with \(playersStillInTheGame[loopableIndex(playerIndexOrder, range: playersStillInTheGame.count)].name)"
                        self.run(endMyTurn)
                    }
                } else {
                    if myPlayer.card.readableRank != "King" {
                        self.tradeCardWithDeck(myPlayer)
                        GS.bluetoothService.sendData("hittingDeck\(myPlayer.name)")
                        let wait  = SKAction.wait(forDuration: 3)
                        let block = SKAction.run({self.runEndOfRoundFunctions(); self.GS.bluetoothService.sendData("endRound")})
                        self.run(SKAction.sequence([wait, block]))
                    }
                }
                self.removePlayerOptions()
            }
            if atPoint(touch.location(in: self)) == updateLabel {
                runEndOfGameFunctions()
            }
            
            if atPoint(touch.location(in: self)) == endGameButton {
                endGameAndGoToConnectionScene()
            }
        }
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func showPlayerOptions() {
        self.addChild(stickButton)
        self.addChild(stickButtonImage)
        self.addChild(tradeButton)
        self.addChild(tradeButtonImage)
    }
    
    func removePlayerOptions() {
        stickButton.removeFromParent()
        stickButtonImage.removeFromParent()
        tradeButton.removeFromParent()
        tradeButtonImage.removeFromParent()
    }
    
    func nextPlayerGoes() {
        var x: Int = 0
        while GS.orderedPlayers[loopableIndex(playerIndexOrder + x, range: GS.orderedPlayers.count)].isStillInGame == false {
            x += 1
        }
        GS.bluetoothService.sendData("updateLabelIt's \(GS.orderedPlayers[loopableIndex(playerIndexOrder + x, range: GS.orderedPlayers.count)].name)'s turn to go.")
        GS.bluetoothService.sendData("playersTurn\(GS.orderedPlayers[loopableIndex(playerIndexOrder + x, range: GS.orderedPlayers.count)].name)")
        self.updateLabel.text = "It's \(GS.orderedPlayers[loopableIndex(playerIndexOrder + x, range: GS.orderedPlayers.count)].name)'s turn to go."
    }
    
    func tradeCardWithPlayer(_ playerOne: Player, playerTwo: Player) {
        if playerTwo.card.rank < playerOne.card.rank {
            run(SKAction.sequence([SKAction.wait(forDuration: 1.1), SKAction.run({self.updateLabel.text = "MODI"})]))
        }
        if playerTwo.card.rank == playerOne.card.rank {
            run(SKAction.sequence([SKAction.wait(forDuration: 1.1), SKAction.run({self.updateLabel.text = "Dirty Dan!"})]))
        }
        let temp = playerOne.card
        playerOne.card = playerTwo.card
        playerTwo.card = temp
        playerOne.card.owner = playerOne
        playerTwo.card.owner = playerTwo
        moveCards(playerOne.card, card2: playerTwo.card)
        
    }
    
    func tradeCardWithDeck(_ player: Player) {
        let block = {
            let card = self.deckOfCards.last!
            let xPos = player.card.position.x + (cos(player.card.zRotation) * 10)
            let yPos = player.card.position.y + (sin(player.card.zRotation) * 10)
            let moveCard = SKAction.move(to: CGPoint(x: xPos, y: yPos), duration: 0.5)
            let rotateCard = SKAction.rotate(toAngle: player.card.zRotation, duration: 0.5)
            let flipCard = SKAction.run({card.texture = card.frontTexture})
            card.run(rotateCard)
            card.run(SKAction.sequence([moveCard, flipCard]))
            card.zPosition = player.card.zPosition + 1
            player.card = card
            player.card.owner = player
            self.cardsInPlay.append(card)
            self.deckOfCards.removeLast()
        }
        if deckOfCards.count > 0 {
            self.run(SKAction.run(block))
        } else {
            self.reloadDeck()
            self.run(SKAction.sequence([SKAction.wait(forDuration: 52 * 0.05), SKAction.run(block)]))
        }
    }
    
    func moveCards(_ card1: Card, card2: Card) {
        let moveToCard1 = SKAction.move(to: card1.position, duration: 0.5)
        let moveToCard2 = SKAction.move(to: card2.position, duration: 0.5)
        let rotateCard1 = SKAction.rotate(toAngle: card2.zRotation, duration: 0.5)
        let rotateCard2 = SKAction.rotate(toAngle: card1.zRotation, duration: 0.5)
        let flip = SKAction.run({
            if card1.owner.peerID == self.myPlayer.peerID || card2.owner.peerID == self.myPlayer.peerID {
                if self.myPlayer.card.texture == self.myPlayer.card.backTexture {
                    self.myPlayer.card.flip()
                }
            }
            
        })
        
        if card1.texture == card1.frontTexture {
            card1.flip()
        }
        if card2.texture == card2.frontTexture {
            card2.flip()
        }
        
        card1.run(moveToCard2)
        card1.run(rotateCard1)
        card2.run(moveToCard1)
        card2.run(rotateCard2)
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), flip]))
    }
    
    func loopableIndex(_ index: Int, range: Int) -> Int {
        var x = index
        if range == 1 {
            x = 0
        } else {
            while x > (range - 1) {
                x = x - range
            }
        }
        return x
    }
    
    
    func placeDeckOnScreen() {
        var x: CGFloat = 1
        for card in deck.cards {
            addCard(card: card, zPos: x)
            x = x + 1
        }
    }
    func resizeCard(_ card: Card) -> CGSize {
        let aspectRatio = card.size.width / card.size.height
        let setHeight = self.frame.size.height / 4.5
        return CGSize(width: setHeight * aspectRatio, height: setHeight)
    }
    
    func addCard(card: Card, zPos: CGFloat) {
        let randomRotation = arc4random_uniform(10)
        card.size = resizeCard(card)
        card.position = self.deckPosition
        card.zRotation = (CGFloat(randomRotation) - 5) * CGFloat(M_PI) / 180
        card.zPosition = zPos
        card.isUserInteractionEnabled = true
        addChild(card)
        deckOfCards.append(card)
        deck.cards.remove(at: 0)
    }
    
    func dealCards() {
        removeLeaderBoard()
        
        let referenceCard = Card(suit: "spades", readableRank: "Ace", rank: 1)
        referenceCard.size = resizeCard(referenceCard)
        var radius = (frame.size.height / 2) - (referenceCard.frame.height)
        let centerPoint = CGPoint(x: frame.maxX / 4, y: frame.maxY / 2)
        
        referenceCard.zRotation = 90.toRadians()
        referenceCard.position.x = centerPoint.x - radius
        referenceCard.size = resizeCard(referenceCard)
        
        while referenceCard.frame.minX < 0 {
            radius = radius - 8
            referenceCard.position.x = centerPoint.x - radius
        }
        
        let block = {
            let insideBlock = {
                let dealerHopper = CGFloat(self.roundNumber - 1)
                let totalPlayers = CGFloat(self.GS.orderedPlayers.count)
                let cardPlaces = CGFloat(self.playerLabels.count)
                let angle: CGFloat = (((360 / totalPlayers) * (2 + cardPlaces + dealerHopper - CGFloat(self.playerIndexOrder))) - 90).toRadians()
                
                print("Amount of players: \(self.GS.orderedPlayers.count)")
                print("\(self.myPlayer.name)'s order is: \(self.playerIndexOrder)")
                print("Player Labels: \(self.playerLabels.count)")
                let position = CGPoint(x: centerPoint.x + (cos(angle) * radius), y: centerPoint.y + (sin(angle) * radius))
                let actionMove = SKAction.move(to: position, duration: 0.5)
                let actionRotate = SKAction.rotate(toAngle: (angle + 90.toRadians()), duration: 0.5)
                
                let playerLabel = SKLabelNode(fontNamed: "Chalkboard SE")
                let fivePercentWidth = self.frame.size.width * 0.05
                let fivePercentHeight = self.frame.size.height * 0.05
                playerLabel.text = self.GS.orderedPlayers[self.loopableIndex(self.playerLabels.count + Int(dealerHopper + 1), range: self.GS.orderedPlayers.count)].name
                playerLabel.fontSize = 12
                playerLabel.position = CGPoint(x: position.x + (cos(angle) * ((self.deckOfCards.last!.size.width / 2) + fivePercentWidth)), y: position.y + (sin(angle) * ((self.deckOfCards.last!.size.height / 2) + fivePercentHeight)))
                playerLabel.zRotation = angle + 90.toRadians()
                playerLabel.zPosition = 1.0
                self.addChild(playerLabel)
                self.playerLabels.append(playerLabel)
                
                // If the player still has lives, give him a card
                if self.GS.orderedPlayers[self.loopableIndex(self.playerLabels.count + Int(dealerHopper), range: self.GS.orderedPlayers.count)].isStillInGame {
                    self.deckOfCards.last?.run(actionMove)
                    self.deckOfCards.last?.run(actionRotate)
                    self.cardsInPlay.append(self.deckOfCards.last!)
                    self.GS.orderedPlayers[self.loopableIndex(self.playerLabels.count + Int(dealerHopper), range: self.GS.orderedPlayers.count)].card = self.deckOfCards.last!
                    self.deckOfCards.last!.owner = self.GS.orderedPlayers[self.loopableIndex(self.playerLabels.count + Int(dealerHopper), range: self.GS.orderedPlayers.count)]
                    if self.deckOfCards.last!.owner.peerID == self.myPlayer.peerID {
                        self.run(SKAction.sequence([SKAction.wait(forDuration: 0.6), SKAction.run({self.myPlayer.card.flip()})]))
                    }
                    self.deckOfCards.removeLast()
                }
            }
            if self.deckOfCards.count < 1 {
                self.reloadDeck()
                self.run(SKAction.sequence([SKAction.wait(forDuration: Double(self.trashDeck.cards.count + 2) * 0.05), SKAction.run(insideBlock)]))
            } else {
                self.run(SKAction.run(insideBlock))
            }
        }
        let wait = SKAction.wait(forDuration: 0.5)
        let runBlock = SKAction.run(block)
        let sequence = SKAction.sequence([runBlock, wait])
        let actionRepeat = SKAction.repeat(sequence, count: GS.orderedPlayers.count)
        
        print(self.trashDeck.cards.count)
        print(self.deckOfCards.count)
        
        self.run(actionRepeat)
    }
    
    func reloadDeck() {
        trashDeck.shuffle()
        trashDeck.shuffle()
        self.deckOfCards = []
        for card in 0 ..< trashDeck.cards.count {
            if trashDeck.cards[card].texture == trashDeck.cards[card].frontTexture {
                trashDeck.cards[card].flip()
            }
            let move = SKAction.move(to: deckPosition, duration: 0.05)
            trashDeck.cards[card].zPosition = CGFloat(card)
            trashDeck.cards[card].run(move)
            self.deckOfCards.append(trashDeck.cards[card])
        }
    }
    
    func runEndOfRoundFunctions() {
        //Calling this before livecountcheck prevents the current dealer from being removed before recording his index
        var currentDealerIndex: Int = {
            var index: Int = 0
            for player in 0 ..< self.GS.orderedPlayers.count {
                if self.GS.orderedPlayers[player].peerID == self.GS.currentDealer.peerID {
                    index = player + 1
                }
            }
            return index
        }()
        
        let setUpForNextRound = SKAction.run({
            
            while self.GS.orderedPlayers[self.loopableIndex(currentDealerIndex, range: self.GS.orderedPlayers.count)].isStillInGame == false {
                currentDealerIndex += 1
            }
            
            let nextPlayer = self.GS.orderedPlayers[self.loopableIndex(currentDealerIndex, range: self.GS.orderedPlayers.count)]
            
            self.GS.currentDealer = nextPlayer
            let goIntoNextRound = SKAction.run({
                if self.playersStillInTheGame.count != 1 {
                    self.runBeginingOfRoundFunctions()
                }
            })
            self.run(goIntoNextRound)
        })
        
        let lowestCardRank: Int = {
            var rank = 13
            for player in self.playersStillInTheGame {
                if player.card.rank < rank {
                    rank = player.card.rank
                }
            }
            return rank
        }()
        var playersLost: [String] = []
        for card in cardsInPlay {
            if card.texture == card.backTexture {
                card.flip()
            }
        }
        for player in playersStillInTheGame {
            if player.card.rank == lowestCardRank {
                player.lives = player.lives - 1
                playersLost.append(player.name)
            }
        }
        if playersLost.count == 2 {
            self.updateLabel.text = "DOUBLE OUT"
        } else if playersLost.count > 2 {
            self.updateLabel.text = "MULTIPLE OUT"
        } else {
            self.updateLabel.text = "\(playersLost[0]) lost this round."
        }
        
        let waitFive = SKAction.wait(forDuration: 4)
        let trashCards = SKAction.run({self.sendCardsToTrash()})
        
        let showLeaderBoard = SKAction.run({self.setUpLeaderBoard()})
        let checkLiveCount = SKAction.run({

            var x = 0
            for player in self.playersStillInTheGame {
                if player.lives < 1 {
                    player.isStillInGame = false
                    self.playersStillInTheGame.remove(at: x)
                }
                x += 1
            }
            
            if self.playersStillInTheGame.count == 1 {
                self.itsTheEndOfTheGame = true
                self.runEndOfGameFunctions()
            } else {
                self.run(setUpForNextRound)
            }
        })
        
        self.run(SKAction.sequence([waitFive, trashCards, showLeaderBoard, checkLiveCount]))
    
        
        // IF EVERY PLAYER ONLY HAS 0 LIVES LEFT -> GO INTO DOUBLE GAME
        
    }
    
    func sendCardsToTrash() {
        for card in cardsInPlay {
            let randomRotation = (CGFloat(arc4random_uniform(12)) - 6) * CGFloat(M_PI) / 180
            let moveToTrash = SKAction.move(to: self.trashPosition, duration: 1)
            let rotateToStraight = SKAction.rotate(toAngle: randomRotation, duration: 1)
            
            card.run(moveToTrash)
            card.run(rotateToStraight)
            card.zPosition = 60 - card.zPosition
            cardsInPlay.remove(at: cardsInPlay.index(of: card)!)
            trashDeck.cards.append(card)
            card.owner.card = nil
            card.owner = nil
        }
        
        for playerLabel in playerLabels {
            playerLabel.removeFromParent()
            playerLabels.remove(at: playerLabels.index(of: playerLabel)!)
        }
    }
    
    func runBeginingOfRoundFunctions() {
        if  !itsTheEndOfTheGame {
            roundNumber  = roundNumber + 1
            roundLabel.text = "Round \(roundNumber)"
        
            let wait = SKAction.wait(forDuration: 1.5)
            let addRoundLabel = SKAction.run({self.addChild(self.roundLabel)})
            let removeLabel = SKAction.run({self.roundLabel.removeFromParent()})
            self.run(SKAction.sequence([wait, addRoundLabel, wait, removeLabel]))
            
            if myPlayer.peerID == GS.currentDealer.peerID {
                updateLabel.text = "\(myPlayer.name) is dealing the cards"
                GS.bluetoothService.sendData("updateLabel\(myPlayer.name) is dealing the cards")
                let waitForthree = SKAction.wait(forDuration: 3)
                let addDealButton = SKAction.run({self.addChild(self.dealButton); self.addChild(self.dealButtonImage)})
                self.run(SKAction.sequence([waitForthree, addDealButton]))
            }
        }
        
    }
    
    func runEndOfGameFunctions() {
        self.updateLabel.text = "\(playersStillInTheGame[0].name.uppercased()) WINS THE GAME!"
        let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 1)
        blackBackground.run(SKAction.sequence([SKAction.wait(forDuration: 1), fadeIn]))
        
        let loserLabel: SKLabelNode = blackBackground.childNode(withName: "loserLabel") as! SKLabelNode
        var loserString: String = "Losers: "
        for player in GS.orderedPlayers {
            if player.name != playersStillInTheGame[0].name {
                loserString += player.name + ", "
            }
        }
        loserString.characters.removeLast()
        loserString.characters.removeLast()
        loserLabel.text = loserString
        
        let winnerLabel: SKLabelNode = blackBackground.childNode(withName: "winnerLabel") as! SKLabelNode
        winnerLabel.text = "Winner: " + self.playersStillInTheGame[0].name
        
                
        
        //ADD A BUTTON AT BOTTOM TO GO BACK TO CONNECTION SCENE
    }
    
    func endGameAndGoToConnectionScene() {
        let skView = self.view! as SKView
        let scene = ConnectionScene(fileNamed: "ConnectionScene")
        skView.showsFPS = false
        skView.showsNodeCount = false
        scene?.scaleMode = .resizeFill
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            scene?.scaleMode = .aspectFit
        }
        
        skView.presentScene(scene)
        
        GS.orderedPlayers = []
        GS.currentGameState = .waitingForPlayers
        GS.bluetoothService = nil
    }
    
    
}

extension GameScene: GameSceneDelegate {
    func heresTheNewDeck(_ deck: Deck) {
        self.deck = deck
        placeDeckOnScreen()
    }
    func dealPeersCards() {
        self.dealCards()
    }
    func updateLabel(_ str: String) {
        self.updateLabel.text = str
    }
    func yourTurn() {
        self.showPlayerOptions()
    }
    func playersTradedCards(_ playerOne: Player, playerTwo: Player) {
        self.tradeCardWithPlayer(playerOne, playerTwo: playerTwo)
    }
    func playerTradedWithDeck(_ player: Player) {
        self.tradeCardWithDeck(player)
    }
    func endRound() {
        self.runEndOfRoundFunctions()
    }
    func trashCards() {
        self.sendCardsToTrash()
    }
}




