//
//  Mushroom.swift
//  Swiftipede
//
//  Created by Erik M. Buck on 3/27/24.
//

import SpriteKit

/// \ref issue2 \ref issue3 \ref issue37 \ref issue38
class Mushroom : SKNode {
   var mushroomSprite = Mushroom.mushroomStates[0].copy() as! SKSpriteNode
   var state = 0
   
   /// \ref issue6 \ref issue2 \ref issue3 \ref issue38
   static var mushroomStates = [
      GameScene.prototypeNodes.childNode(withName: "Mushroom100")!,
      GameScene.prototypeNodes.childNode(withName: "Mushroom75")!,
      GameScene.prototypeNodes.childNode(withName: "Mushroom50")!,
      GameScene.prototypeNodes.childNode(withName: "Mushroom25")!,
   ]
   
   /// \ref issue2 \ref issue3 \ref issue37 \ref issue38
   func spawn() {
      mushroomSprite.position = CGPoint(x: 0, y: 0)
      addChild(mushroomSprite)
      state = 0
   }
   
   func heal() {
      mushroomSprite.removeFromParent()
      state = 0
      if state < Mushroom.mushroomStates.count {
         mushroomSprite = Mushroom.mushroomStates[state].copy() as! SKSpriteNode
         mushroomSprite.position = CGPoint(x: 0, y: 0)
         addChild(mushroomSprite)
      }
   }
   /// \ref issue2 \ref issue3 \ref issue37 \ref issue38
   override func isMushroom () -> Bool {
      return true
   }
   
   /// \ref issue2 \ref issue3 \ref issue37 \ref issue38 \ref issue36
   override func takeDamage(scene : GameScene) {
      mushroomSprite.removeFromParent()
      state += 1
      if state < Mushroom.mushroomStates.count {
         mushroomSprite = Mushroom.mushroomStates[state].copy() as! SKSpriteNode
         mushroomSprite.position = CGPoint(x: 0, y: 0)
         addChild(mushroomSprite)
      } else {
         scene.incrementScore(1)
         removeFromParent()
      }
   }
}
