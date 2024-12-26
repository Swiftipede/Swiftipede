//
//  Spider.swift
//  Swiftipede
//
//  Created by Erik M. Buck on 12/24/24.
//

import SpriteKit

/// \ref issue2 \ref issue3 \ref issue37 \ref issue38
class Spider : SKNode {
   override func takeDamage(scene : GameScene) {
      scene.killCurrentSpider()
   }
}
