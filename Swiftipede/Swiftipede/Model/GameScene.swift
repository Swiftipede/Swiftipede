//
//  GameScene.swift
//  Swiftipede
//
//  Created by Erik M. Buck on 3/17/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
   /// \ref issue5
   static let gameAreaWidth = Int32(25)
   
   /// \ref issue5
   static let gameAreaHeight = Int32(40)
   
   /// \ref issue9
   static let prototypeNodes = SKScene(fileNamed: "PrototypesScene.sks")!
   
   /// \ref issue9
   static let cenitpedeBody = prototypeNodes.childNode(withName: "CentipedeBody")!
   
   /// \ref issue9
   static func makeCentipedeBodySegment() -> SKSpriteNode {
      let newBodySegement = GameScene.cenitpedeBody.copy() as! SKSpriteNode
      newBodySegement.isPaused = false
      return newBodySegement
   }
   
   /// \ref issue9
   func convertGAtoScene(gaX: Int32, gaY:Int32) -> CGPoint {
      return CGPoint(x: convertGAXToSceneX(gaX: gaX), y: convertGAYToSceneY(gaY: gaY))
   }
   
   /// \ref issue5 : Convert from game coordinates to scene coordinates
   func convertGAXToSceneX(gaX : Int32) -> CGFloat {
      return (0.5 + CGFloat(gaX)) * frame.width / CGFloat(GameScene.gameAreaWidth)
      
   }
   
   /// \ref issue5 : Convert from game coordinates to scene coordinates
   func convertGAYToSceneY(gaY : Int32) -> CGFloat {
      return (0.5 + CGFloat(gaY)) * frame.height / CGFloat(GameScene.gameAreaHeight)
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
      // \ref issue9
      let newSegment0 = GameScene.makeCentipedeBodySegment()
      newSegment0.position = convertGAtoScene(gaX: 0, gaY: 0)
      addChild(newSegment0)
      let newSegment1 = GameScene.makeCentipedeBodySegment()
      newSegment1.position = convertGAtoScene(gaX: 24, gaY: 39)
      addChild(newSegment1)
   }
   
   override func update(_ currentTime: TimeInterval) {
   }
}
