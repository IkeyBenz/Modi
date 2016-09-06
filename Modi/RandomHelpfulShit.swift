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
