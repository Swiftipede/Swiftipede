//
//  GameScene.swift
//  Swiftipede
//
//  Created by Erik M. Buck on 3/17/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
   static let gameAreaWidth = Int32(25)
   static let gameAreaHeight = Int32(40)
   
   /// \ref issue5 : Convert from game coordinates to scene coordinates
   func convertGAXToSceneX(gaX : CGFloat) -> CGFloat {
      return gaX * frame.width / CGFloat(GameScene.gameAreaWidth)
      
   }
   
   /// \ref issue5 : Convert from game coordinates to scene coordinates
   func convertGAYToSceneY(gaY : CGFloat) -> CGFloat {
      return gaY * frame.height / CGFloat(GameScene.gameAreaHeight)
   }
   
   /// \ref issue5 : Convert from game coordinates to scene coordinates
   func convertSceneXtoGAX(position: CGPoint) -> CGFloat {
      return position.x * CGFloat(GameScene.gameAreaWidth) / frame.width
   }
   
   /// \ref issue5 : Convert from game coordinates to scene coordinates
   func convertSceneYtoGAY(position: CGPoint) -> CGFloat {
      return position.y * CGFloat(GameScene.gameAreaHeight) / frame.height
   }

   override func didMove(to view: SKView) {
   }
   
   override func update(_ currentTime: TimeInterval) {
   }
}
