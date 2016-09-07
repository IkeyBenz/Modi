//
//  RandomHelpfulShit.swift
//  Modii
//
//  Created by Ikey Benzaken on 7/27/16.
//  Copyright © 2016 Ikey Benzaken. All rights reserved.
//

import Foundation
import SpriteKit

extension CGFloat {
    func toRadians() -> CGFloat {
        return self  * CGFloat(M_PI) / 180
    }
}

extension Int {
    func toRadians() -> CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180
    }
}

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = indexOf(object) {
            removeAtIndex(index)
        }
    }
}
