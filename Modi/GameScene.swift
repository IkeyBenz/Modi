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
    let dealButton = SKLabelNode(fontNamed: "Chalkduster")
    var dealButtonImage = SKSpriteNode(imageNamed: "Button")
    var deckOfCards: [Card] = []
    var tradeButton = SKLabelNode(fontNamed: "Chalkduster")
    var tradeButtonImage = SKSpriteNode(imageNamed: "Button")
    var stickButton = SKLabelNode(fontNamed: "Chalkduster")
    var stickButtonImage = SKSpriteNode(imageNamed: "Button")
    var updateLabel = SKLabelNode(fontNamed: "Chalkduster")
    var roundLabel = SKLabelNode(fontNamed: "Chalkduster")
    var roundNubmer: Int = 0
    var myTurnToDeal: Bool = false
    var deckPosition: CGPoint!
    var playerLabels: [SKLabelNode] = []
    var playerLabelsInLeaderBoard: [SKLabelNode] = []
    var leaderBoardComponenets: [SKSpriteNode] = []
    var playersInOrderOfLives: [Player] = []
    var playersStillInTheGame: [Player] = []
    var itsTheEndOfTheGame: Bool = false
    
    let playerIndexOrder: Int = {
        let index: Int = 0
        for x in 0 ..< GameStateSingleton.sharedInstance.orderedPlayers.count {
            if GameStateSingleton.sharedInstance.orderedPlayers[x].peerID == GameStateSingleton.sharedInstance.bluetoothService.session.myPeerID {
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
    
    
    
    override func didMoveToView(view: SKView) {
        
        GS.bluetoothService.gameSceneDelegate = self
        GS.currentGameState = .InSession
        playersInOrderOfLives = GS.orderedPlayers
        playersStillInTheGame = GS.orderedPlayers
        setUpLeaderBoard()
        
        
        let background = SKSpriteNode(imageNamed: "Felt")
        background.size = self.frame.size
        background.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        
        
        let threePercentWidth = self.frame.maxX * 0.03
        dealButton.fontSize = 24
        dealButton.text = "Deal Cards"
        dealButton.position = CGPoint(x: frame.maxX - (dealButton.frame.width / 2) - threePercentWidth, y: CGRectGetMaxY(self.frame) / 14)
        dealButton.zPosition = 1
        setupButton(dealButtonImage, buttonLabel: dealButton)
        
        if GS.currentDealer.peerID == myPlayer.peerID {
            deck.shuffle()
            placeDeckOnScreen()
            GS.bluetoothService.sendData("deckString" + deck.cardsString)
        }
        
        tradeButton.text = "Swap"
        stickButton.text = "Stick"
        tradeButton.fontSize = 24
        stickButton.fontSize = 24
        tradeButton.position = CGPointMake(frame.maxX * 0.68, frame.maxY * 0.7)
        stickButton.position = CGPointMake(CGRectGetMaxX(tradeButton.frame) + (stickButton.frame.width / 1.25), tradeButton.position.y)
        tradeButton.zPosition = 1.0
        stickButton.zPosition = 1.0
        setupButton(tradeButtonImage, buttonLabel: tradeButton)
        setupButton(stickButtonImage, buttonLabel: stickButton)
        
        roundLabel.text = "Round 1"
        roundLabel.position = CGPoint(x: frame.maxX / 2, y: frame.maxY / 2)
        roundLabel.fontSize = 24
        roundLabel.zPosition = 1
        
        updateLabel.text = "Loading Game..."
        updateLabel.position = CGPointMake(frame.maxX * 0.75, frame.maxY - 25)
        updateLabel.zPosition = 1
        updateLabel.fontSize = 14
        
        
        self.addChild(background)
        self.addChild(updateLabel)
        runBeginingOfRoundFunctions()
        
    }
    
    func setUpLeaderBoard() {
        let leaderBoardBorder = SKSpriteNode(imageNamed: "TableViewBorder")
        leaderBoardBorder.centerRect = CGRectMake(10 / 458, 9 / 150, 438 / 458, 132 / 150)
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
                print("Lives in order: \(lives.sort(>))")
                return lives.sort(>)
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
            let playerLabel = SKLabelNode(fontNamed: "Chalkduster")
            let fadeLabel = SKAction.fadeOutWithDuration(3)
            let removeLabel = SKAction.runBlock({playerLabel.removeFromParent()})
            playerLabel.text = "\(x + 1)) \(playersInOrderOfLives[x].name): \(playersInOrderOfLives[x].lives) lives"
            playerLabel.zPosition = 11
            playerLabel.fontSize = 12
            cellView.xScale = (leaderBoardBorder.frame.width * 0.85) / cellView.frame.width
            cellView.position = CGPoint(x: leaderBoardBorder.position.x, y: CGRectGetMaxY(leaderBoardBorder.frame) - (CGFloat(x) * cellView.frame.height))
            playerLabel.position = CGPoint(x: cellView.position.x, y: cellView.position.y - (cellView.frame.height / 1.5))
            cellView.anchorPoint = CGPoint(x: 0.5, y: 1)
            cellView.zPosition = 11
            self.addChild(cellView)
            self.addChild(playerLabel)
            if playersInOrderOfLives[x].lives == 0 {
                
                playerLabel.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({playerLabel.fontColor = UIColor.redColor()})]))
                playerLabel.runAction(SKAction.sequence([SKAction.waitForDuration(1), fadeLabel]))
                self.runAction(SKAction.sequence([SKAction.waitForDuration(3), removeLabel]))
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
    
    func setupButton(buttonImage: SKSpriteNode, buttonLabel: SKLabelNode) {
        buttonImage.position = buttonLabel.position
        buttonImage.zPosition = buttonLabel.zPosition - 0.1
        buttonImage.centerRect = CGRectMake(17.0/62.0, 17.0/74.0, 28.0/62.0, 39.0/74.0);
        buttonImage.anchorPoint = CGPoint(x: 0.5, y: 0.25)
        buttonImage.xScale = buttonLabel.frame.width / buttonImage.frame.width + 0.5
        buttonImage.yScale = buttonLabel.frame.height / buttonImage.frame.height + 0.5
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let wait = SKAction.waitForDuration(2)
        let block = SKAction.runBlock({self.nextPlayerGoes()})
        let endMyTurn = SKAction.sequence([wait, block])
        for touch in touches {
            
            if nodeAtPoint(touch.locationInNode(self)) == dealButton {
                dealCards()
                GS.bluetoothService.sendData("dealCards")
                dealButton.removeFromParent()
                dealButtonImage.removeFromParent()
                self.runAction(endMyTurn)
            }
            if nodeAtPoint(touch.locationInNode(self)) == stickButton {
                if myPlayer.peerID == GS.currentDealer.peerID {
                    self.runEndOfRoundFunctions()
                    GS.bluetoothService.sendData("endRound")
                } else {
                    self.runAction(endMyTurn)
                }
                GS.bluetoothService.sendData("updateLabel\(myPlayer.name) stuck")
                self.updateLabel.text = "\(myPlayer.name) stuck"
                self.removePlayerOptions()
            }
            if nodeAtPoint(touch.locationInNode(self)) == tradeButton {
                if myPlayer.peerID != GS.currentDealer.peerID {
                    if myPlayer.card.readableRank == "King" || GS.orderedPlayers[loopableIndex(playerIndexOrder, range: GS.orderedPlayers.count)].card.readableRank == "King" {
                        if myPlayer.card.readableRank == "King" {
                            self.updateLabel.text = "You can't trade your king!"
                            GS.bluetoothService.sendData("updateLabel\(myPlayer.name) stuck")
                            self.runAction(endMyTurn)
                        }
                        if GS.orderedPlayers[loopableIndex(playerIndexOrder, range: GS.orderedPlayers.count)].card.readableRank == "King" {
                            self.updateLabel.text = "\(GS.orderedPlayers[loopableIndex(playerIndexOrder, range: GS.orderedPlayers.count)].name) has a king!"
                            GS.bluetoothService.sendData("updateLabel\(myPlayer.name) tried to swap with \(GS.orderedPlayers[loopableIndex(playerIndexOrder, range: GS.orderedPlayers.count)].name)")
                            self.runAction(endMyTurn)
                        }
                    } else {
                        self.tradeCardWithPlayer(myPlayer, playerTwo: GS.orderedPlayers[loopableIndex(playerIndexOrder, range: GS.orderedPlayers.count)])
                        GS.bluetoothService.sendData("playerTraded\(myPlayer.name).\(GS.orderedPlayers[loopableIndex(playerIndexOrder, range: GS.orderedPlayers.count)].name)")
                        self.updateLabel.text = "\(myPlayer.name) traded cards with \(GS.orderedPlayers[loopableIndex(playerIndexOrder, range: GS.orderedPlayers.count)].name)"
                        self.runAction(endMyTurn)
                    }
                } else {
                    if myPlayer.card.readableRank != "King" {
                        self.tradeCardWithDeck(myPlayer)
                        GS.bluetoothService.sendData("hittingDeck\(myPlayer.name)")
                        let wait  = SKAction.waitForDuration(3)
                        let block = SKAction.runBlock({self.runEndOfRoundFunctions(); self.GS.bluetoothService.sendData("endRound")})
                        self.runAction(SKAction.sequence([wait, block]))
                    }
                }
                self.removePlayerOptions()
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
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
        //FIGURE OUT WHO THE NEXT PLAYER STILL ALIVE IS
        var nextPlayer: Player = GS.orderedPlayers[loopableIndex(playerIndexOrder, range: GS.orderedPlayers.count)]
        var stopper: Bool = true
        var x: Int = 0
        
        while stopper {
            if GS.orderedPlayers[loopableIndex(playerIndexOrder + x, range: GS.orderedPlayers.count)].isStillInGame {
                nextPlayer = GS.orderedPlayers[loopableIndex(playerIndexOrder + x, range: GS.orderedPlayers.count)]
                stopper = false
            } else {
                x = x + 1
            }
        }
        
        GS.bluetoothService.sendData("updateLabelIt's \(nextPlayer.name)'s turn to go.")
        GS.bluetoothService.sendData("playersTurn\(nextPlayer.name)")
        self.updateLabel.text = "It's \(nextPlayer.name)'s turn to go."
    }
    
    func tradeCardWithPlayer(playerOne: Player, playerTwo: Player) {
        let temp = playerOne.card
        playerOne.card = playerTwo.card
        playerTwo.card = temp
        playerOne.card.owner = playerOne
        playerTwo.card.owner = playerTwo
        moveCards(playerOne.card, card2: playerTwo.card)
        
    }
    
    func tradeCardWithDeck(player: Player) {
        if deckOfCards.count > 0 {
            let card = deckOfCards.last!
            let xPos = player.card.position.x + (cos(player.card.zRotation) * 10)
            let yPos = player.card.position.y + (sin(player.card.zRotation) * 10)
            let moveCard = SKAction.moveTo(CGPoint(x: xPos, y: yPos), duration: 0.5)
            let rotateCard = SKAction.rotateToAngle(player.card.zRotation, duration: 0.5)
            let flipCard = SKAction.runBlock({card.texture = card.frontTexture})
            card.runAction(rotateCard)
            card.runAction(SKAction.sequence([moveCard, flipCard]))
            card.zPosition = player.card.zPosition + 1
            player.card = card
            player.card.owner = player
            cardsInPlay.append(card)
            deckOfCards.removeLast()
        }
    }
    
    func moveCards(card1: Card, card2: Card) {
        let moveToCard1 = SKAction.moveTo(card1.position, duration: 0.5)
        let moveToCard2 = SKAction.moveTo(card2.position, duration: 0.5)
        let rotateCard1 = SKAction.rotateToAngle(card2.zRotation, duration: 0.5)
        let rotateCard2 = SKAction.rotateToAngle(card1.zRotation, duration: 0.5)
        let flip = SKAction.runBlock({
            if self.myPlayer.card.texture == self.myPlayer.card.backTexture {
                self.myPlayer.card.flip()
            }
        })
        
        if card1.texture == card1.frontTexture {
            card1.flip()
        }
        if card2.texture == card2.frontTexture {
            card2.flip()
        }
        
        card1.runAction(moveToCard2)
        card1.runAction(rotateCard1)
        card2.runAction(moveToCard1)
        card2.runAction(rotateCard2)
        
        self.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), flip]))
    }
    
    func loopableIndex(index: Int, range: Int) -> Int {
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
            addCard(card, zPos: x)
            x = x + 1
        }
    }
    func resizeCard(card: Card) -> CGSize {
        let aspectRatio = card.size.width / card.size.height
        let setHeight = self.frame.size.height / 4.5
        return CGSize(width: setHeight * aspectRatio, height: setHeight)
    }
    
    func addCard(card: Card, zPos: CGFloat) {
        let randomRotation = arc4random_uniform(10)
        let twentyFiveOfDealLabel = CGRectGetMinX(dealButton.frame) + (dealButton.frame.width * 0.25)
        card.size = resizeCard(card)
        card.position = CGPoint(x: twentyFiveOfDealLabel, y: frame.maxY / 4)
        card.zRotation = (CGFloat(randomRotation) - 5) * CGFloat(M_PI) / 180
        card.zPosition = zPos
        card.userInteractionEnabled = true
        addChild(card)
        deckOfCards.append(card)
        deck.cards.removeAtIndex(0)
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
        
        while CGRectGetMinX(referenceCard.frame) < 0 {
            radius = radius - 8
            referenceCard.position.x = centerPoint.x - radius
        }
        
        let block = {
            let angle: CGFloat = (((360 / CGFloat(self.GS.orderedPlayers.count)) * CGFloat(self.cardsInPlay.count + (2 - self.playerIndexOrder))).toRadians()) - 90.toRadians()
            let position = CGPointMake(centerPoint.x + (cos(angle) * radius), centerPoint.y + (sin(angle) * radius))
            let actionMove = SKAction.moveTo(position, duration: 0.5)
            let actionRotate = SKAction.rotateToAngle((angle + 90.toRadians()), duration: 0.5)
            
            
            let playerLabel = SKLabelNode(fontNamed: "Chalkduster")
            let fivePercentWidth = self.frame.size.width * 0.05
            let fivePercentHeight = self.frame.size.height * 0.05
            playerLabel.text = self.GS.orderedPlayers[self.loopableIndex(self.cardsInPlay.count + 1, range: self.GS.orderedPlayers.count)].name
            playerLabel.fontSize = 12
            playerLabel.position = CGPointMake(position.x + (cos(angle) * ((self.deckOfCards.last!.size.width / 2) + fivePercentWidth)), position.y + (sin(angle) * ((self.deckOfCards.last!.size.height / 2) + fivePercentHeight)))
            playerLabel.zRotation = angle + 90.toRadians()
            playerLabel.zPosition = 1.0
            self.addChild(playerLabel)
            self.playerLabels.append(playerLabel)
            
            // If the player still has lives, give him a card
            if self.GS.orderedPlayers[self.loopableIndex(self.cardsInPlay.count + 1, range: self.GS.orderedPlayers.count)].isStillInGame {
                self.deckOfCards.last?.runAction(actionMove)
                self.deckOfCards.last?.runAction(actionRotate)
                self.cardsInPlay.append(self.deckOfCards.last!)
                self.GS.orderedPlayers[self.loopableIndex(self.cardsInPlay.count, range: self.GS.orderedPlayers.count)].card = self.deckOfCards.last!
                self.deckOfCards.last!.owner = self.GS.orderedPlayers[self.loopableIndex(self.cardsInPlay.count, range: self.GS.orderedPlayers.count)]
                if self.deckOfCards.last!.owner.peerID == self.myPlayer.peerID {
                    self.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), SKAction.runBlock({self.myPlayer.card.flip()})]))
                }
                self.deckOfCards.removeLast()
            }
        }
        let wait = SKAction.waitForDuration(0.5)
        let runBlock = SKAction.runBlock(block)
        let sequence = SKAction.sequence([runBlock, wait])
        let actionRepeat = SKAction.repeatAction(sequence, count: GS.orderedPlayers.count)
        self.runAction(actionRepeat)
    }
    
    func runEndOfRoundFunctions() {
        
        let currentDealerIndex: Int = {
            var index: Int = 0
            for player in 0 ..< self.playersStillInTheGame.count - 1{
                if playersStillInTheGame[player].peerID == GS.currentDealer.peerID {
                    index = player
                }
            }
            return index
        }()
        var nextPlayer = playersStillInTheGame[loopableIndex(currentDealerIndex + 1, range: playersStillInTheGame.count)]
        
        let setUpForNextRound = SKAction.runBlock({
            print("Even though this is in a block it already got called.")
            var x = 1
            while nextPlayer.isStillInGame == false {
                nextPlayer = self.playersStillInTheGame[self.loopableIndex(currentDealerIndex + x, range: self.playersStillInTheGame.count)]
                x = x + 1
                print(nextPlayer.name)
            }

            
            self.GS.currentDealer = nextPlayer
            let goIntoNextRound = SKAction.runBlock({
                if self.playersStillInTheGame.count != 1 {
                    self.runBeginingOfRoundFunctions()
                }
            })
            self.runAction(goIntoNextRound)
        })
        
        let lowestCardRank: Int = {
            var rank = 13
            for player in playersStillInTheGame {
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
        
        let waitFive = SKAction.waitForDuration(5)
        let trashCards = SKAction.runBlock({self.sendCardsToTrash()})
        
        let showLeaderBoard = SKAction.runBlock({self.setUpLeaderBoard()})
        let checkLiveCount = SKAction.runBlock({
            for player in 0 ..< self.playersStillInTheGame.count - 1 {
                if self.playersStillInTheGame[player].lives < 1 {
                    self.playersStillInTheGame[player].isStillInGame = false
                    self.playersStillInTheGame.removeAtIndex(player)
                }
            }
//            for otherPlayer in 0 ..< self.playersStillInTheGame.count - 1 {
//                if self.playersStillInTheGame[otherPlayer].isStillInGame == false {
//                    self.playersStillInTheGame.removeAtIndex(otherPlayer)
//                }
//            }
            
            let playersInGameString: String = {
                var str = ""
                for player in self.playersStillInTheGame {
                    str = str + player.name + ", "
                }
                return str
            }()
            print(playersInGameString)
            
            if self.playersStillInTheGame.count == 1 {
                self.itsTheEndOfTheGame = true
                self.runEndOfGameFunctions()
            } else {
                self.runAction(setUpForNextRound)
            }
        })
        
        self.runAction(SKAction.sequence([waitFive, trashCards, showLeaderBoard, checkLiveCount]))
        
        //CHECK EACH PLAYERS LIVE COUNT, IF ANY HAVE ZERO, GIVE THEM THE BOOT
    
        
        // IF EVERY PLAYER ONLY HAS 0 LIVES LEFT -> GO INTO DOUBLE GAME
        
    }
    
    func sendCardsToTrash() {
        for card in cardsInPlay {
            let seventyFiveOfDealLabel = CGRectGetMinX(dealButton.frame) + (dealButton.frame.width * 0.75)
            let fiveOfScreenHeight = self.frame.height * 0.05
            let trashPosition = CGPoint(x: seventyFiveOfDealLabel, y:  CGRectGetMaxY(dealButtonImage.frame) + fiveOfScreenHeight + (card.frame.height / 2))
            let randomRotation = (CGFloat(arc4random_uniform(12)) - 6) * CGFloat(M_PI) / 180
            let moveToTrash = SKAction.moveTo(trashPosition, duration: 1)
            let rotateToStraight = SKAction.rotateToAngle(randomRotation, duration: 1)
            
            card.runAction(moveToTrash)
            card.runAction(rotateToStraight)
            card.zPosition = 56 - card.zPosition
            card.owner.card = nil
            card.owner = nil
            cardsInPlay.removeAtIndex(cardsInPlay.indexOf(card)!)
            cardsInTrash.append(card)
        }
        
        for playerLabel in playerLabels {
            playerLabel.removeFromParent()
            playerLabels.removeAtIndex(playerLabels.indexOf(playerLabel)!)
        }
    }
    
    func runBeginingOfRoundFunctions() {
        if  !itsTheEndOfTheGame {
            roundNubmer  = roundNubmer + 1
            roundLabel.text = "Round \(roundNubmer)"
        
            let wait = SKAction.waitForDuration(1.5)
            let addRoundLabel = SKAction.runBlock({self.addChild(self.roundLabel)})
            let removeLabel = SKAction.runBlock({self.roundLabel.removeFromParent()})
            self.runAction(SKAction.sequence([wait, addRoundLabel, wait, removeLabel]))
            
            if myPlayer.peerID == GS.currentDealer.peerID {
                updateLabel.text = "\(myPlayer.name) is dealing the cards"
                GS.bluetoothService.sendData("updateLabel\(myPlayer.name) is dealing the cards")
                let waitForthree = SKAction.waitForDuration(3)
                let addDealButton = SKAction.runBlock({self.addChild(self.dealButton); self.addChild(self.dealButtonImage)})
                self.runAction(SKAction.sequence([waitForthree, addDealButton]))
            }
        }
        
    }
    
    func runEndOfGameFunctions() {
        self.updateLabel.text = "\(playersStillInTheGame[0].name) WINS THE GAME!"
    }
    
    
}

extension GameScene: GameSceneDelegate {
    func heresTheNewDeck(deck: Deck) {
        self.deck = deck
        placeDeckOnScreen()
    }
    func dealPeersCards() {
        self.dealCards()
    }
    func updateLabel(str: String) {
        self.updateLabel.text = str
    }
    func yourTurn() {
        self.showPlayerOptions()
    }
    func playersTradedCards(playerOne: Player, playerTwo: Player) {
        self.tradeCardWithPlayer(playerOne, playerTwo: playerTwo)
    }
    func playerTradedWithDeck(player: Player) {
        self.tradeCardWithDeck(player)
    }
    func endRound() {
        self.runEndOfRoundFunctions()
    }
    func trashCards() {
        self.sendCardsToTrash()
    }
}




