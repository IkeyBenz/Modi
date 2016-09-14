//
//  Deck.swift
//  Modii
//
//  Created by Ikey Benzaken on 7/27/16.
//  Copyright © 2016 Ikey Benzaken. All rights reserved.
//

import Foundation
import SpriteKit


class Deck {
    var cards: [Card] = []
    var cardsString: String = ""
    
    var ranks: [String] = ["Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"]
    var suits: [String] = ["spades", "clubs", "hearts", "diamonds"]
    
    init() {
        for suit in 0 ..< 4 {
            for rank in 0 ..< 13 {
                cards.append(Card(suit: suits[suit], readableRank: ranks[rank], rank: rank + 1))
            }
        }
        for card in cards {
            cardsString += card.readableRank + "." + card.suit + "."
        }
    }
    
    init(withString str: String) {
        
        var ranks: [String] = []
        var suits: [String] = []
        var currentRank: String = ""
        var currentSuit: String = ""
        var buildingRanksString: Bool = true
        
        for character in str.characters {
            if character != "." {
                if buildingRanksString {
                    currentRank += String(character)
                }
                if !buildingRanksString {
                    currentSuit += String(character)
                }
            } else {
                if buildingRanksString {
                    ranks.append(currentRank)
                    currentRank = ""
                    buildingRanksString = false
                } else {
                    suits.append(currentSuit)
                    currentSuit = ""
                    buildingRanksString = true
                }
            }
        }
        for n in 0 ..< 52 {
            var z: Int = 1
            for rank in 0 ..< self.ranks.count {
                if ranks[n] == self.ranks[rank] {
                    z = rank + 1
                }
            }
            cards.append(Card(suit: suits[n], readableRank: ranks[n], rank: z))
        }
        for card in cards {
            cardsString += card.readableRank + "." + card.suit + "."
        }
    }
    
    
    func shuffle() {
        var temp: [Card] = []
        while cards.count > 0 {
            let rand = Int(arc4random_uniform(UInt32(cards.count)))
            temp.append(cards[rand])
            cards.remove(at: rand)
        }
        cards = temp
        
        cardsString = ""
        for card in temp {
            cardsString += card.readableRank + "." + card.suit + "."
        }
    }
}
