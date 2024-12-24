//
//  GameScene.swift
//  Swiftipede
//
//  Created by Erik M. Buck on 3/17/24.
//

import SpriteKit
import GameplayKit

/// \ref issue2 \ref issue3 \ref issue37 \ref issue38
extension SKNode {
   @objc func isMushroom() -> Bool {
      var result = false
      if nil != parent {
         result = parent!.isMushroom()
      }
      return result
   }
   
   @objc func takeDamage(inScene : GameScene) {
      if nil != parent {
         parent!.takeDamage(inScene: inScene)
      }
   }
}

class GameScene: SKScene, Observable {
   /// \ref issue5
   static let gameAreaWidth = Int32(25)
   
   /// \ref issue5
   static let gameAreaHeight = Int32(40)
   
   /// \ref issue19
   static let playAreaStartGAY = Int32(10)

   /// \ref issue29
   static let bulletDeltaY = CGFloat(16) ///<- Arbitrary fast move
   
   static let defaultCentipedeSegementsNumber = UInt32(11)
   static let defaultMushroomsNumber = UInt32(70)

   /// \ref issue9
   static let prototypeNodes = SKScene(fileNamed: "PrototypesScene.sks")!
   
   /// \ref issue9
   static let cenitpedeBody = prototypeNodes.childNode(withName: "CentipedeBody")!
   
   /// \ref issue7 \ref issue8
   static let cenitpedeHead = prototypeNodes.childNode(withName: "CentipedeHead")!
   
   /// \ref issue11 \ref issue12
   static let cenitpedeTail = prototypeNodes.childNode(withName: "CentipedeTail")!

   /// \ref issue20
   static let shooter = prototypeNodes.childNode(withName: "Shooter")!

   /// \ref issue29
   static let bullet = prototypeNodes.childNode(withName: "Bullet")!

   /// \ref issue9
   static func makeCentipedeBodySegment() -> SKSpriteNode {
      let newSegement = GameScene.cenitpedeBody.copy() as! SKSpriteNode
      newSegement.isPaused = false
      return newSegement
   }

   /// \ref issue9
   static func makeCentipedeHeadSegment() -> SKSpriteNode {
      let newSegement = GameScene.cenitpedeHead.copy() as! SKSpriteNode
      newSegement.isPaused = false
      return newSegement
   }
   
   /// \ref issue11
   static func makeCentipedeTailSegment() -> SKSpriteNode {
      let newSegement = GameScene.cenitpedeTail.copy() as! SKSpriteNode
      newSegement.isPaused = false
      return newSegement
   }

   /// \ref issue3 \ref issue25
   @objc dynamic var score = Int(0)
   
   /// \ref issue20
   var shooter = GameScene.shooter.copy() as! SKSpriteNode
   
   /// \ref issue29
   var bullet = GameScene.bullet.copy() as! SKSpriteNode
   
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
   func convertSceneXtoGAX(position: CGPoint) -> Int32 {
      return Int32(position.x * CGFloat(GameScene.gameAreaWidth) / frame.width)
   }
   
   /// \ref issue5 : Convert from game coordinates to scene coordinates
   func convertSceneYtoGAY(position: CGPoint) -> Int32 {
      return Int32(position.y * CGFloat(GameScene.gameAreaHeight) / frame.height)
   }

   /// \ref issue16
   /// \ref issue2 \ref issue3 \ref issue37 \ref issue38
   func spawnMushrooms(number : UInt32) {
      for _ in 0..<number {
         let mushroomGAX = Int32.random(in: 0..<GameScene.gameAreaWidth)
         let mushroomGAY = Int32.random(in: 6..<GameScene.gameAreaHeight) //<- Arbitrary constant 6
         let newMushroom = Mushroom()
         newMushroom.spawn()
         newMushroom.position = convertGAtoScene(gaX: mushroomGAX, gaY: mushroomGAY)
         addChild(newMushroom)
      }
   }
 
   func spawnNewCentipede() {
      let centipede = Centipede()
      centipede.addSegments(number: GameScene.defaultCentipedeSegementsNumber, scene: self)
      centipede.moveHead(scene: self)
   }
   
   func spawnShooter() {
      addChild(shooter)
      shooter.position = CGPoint(x: frame.midX, y: 60) //<- Arbitrary start height
   }
   
   func spawnBullet() {
      bullet.isHidden = true
      addChild(bullet)
   }

   /// \ref issue14 \ref issue16 \ref issue20
   override func didMove(to view: SKView) {
      spawnNewCentipede()
      spawnMushrooms(number: GameScene.defaultMushroomsNumber)
      spawnShooter()
      spawnBullet()
   }
   
   /// \ref issue21
   func moveShooter(position: CGPoint) {
      shooter.position = position
      if bullet.isHidden {
         bullet.position = shooter.position
         bullet.isHidden = false
      }
   }
   
   /// \ref issue3
   func incrementScore(_ amount: Int) {
      score += amount
   }
   
   /// \ref issue2 \ref issue3 \ref issue37 \ref issue38
   func processBulletCollision() {
      let collideNodes = nodes(at: bullet.position).filter { (node : SKNode) in
         node !== self && node !== shooter && node !== bullet
      }
      if 0 < collideNodes.count {
         bullet.isHidden = true
         collideNodes[0].takeDamage(inScene: self)
      }
   }
   
   /// \ref issue29
   override func update(_ currentTime: TimeInterval) {
      if !bullet.isHidden {
         if bullet.position.y > frame.height {
            bullet.isHidden = true
         } else {
            var currentPosition = bullet.position
            currentPosition.y += GameScene.bulletDeltaY
            bullet.position = currentPosition
            processBulletCollision()
         }
      }
   }
}
