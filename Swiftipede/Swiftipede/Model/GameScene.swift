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
   
   /// \ref issue14
   static let defaultCentipedeSegementsNumber = UInt32(11)
   
   /// \ref issue16
   static let defaultMushroomsNumber = UInt32(70)
   
   /// \ref issue26
   static let maximumLivesRemainingNumber = 5
   
   /// \ref issue26
   static let initialLivesRemainingNumber = 2
   
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
   
   /// \ref issue55
   static let delayBetweenMushroomHeal = TimeInterval(0.1)
   
   /// \ref issue49
   static let shootAudioAction = SKAction.playSoundFileNamed("Pew.mp3", waitForCompletion: false)
   
   /// \ref issue50
   static let hitAudioAction = SKAction.playSoundFileNamed("Pop.aiff", waitForCompletion: false)
   
   /// \ref issue55
   static let healAudioAction = SKAction.playSoundFileNamed("Glass.aiff", waitForCompletion: false)
   
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
   
   /// \ref issue26
   @objc dynamic var livesRemainingNumber = -1 // arbitrary invalid number
   
   /// \ref issue54 Keep track of centipedes (and therfore segements) remaining
   var centipedes = Set<Centipede>()
   
   /// \ref issue20
   var shooter = GameScene.shooter.copy() as! SKSpriteNode
   
   /// \ref issue29
   var bullet = GameScene.bullet.copy() as! SKSpriteNode
   
   var gameOverIndicator : SKNode?
   
   var isGameOver = true
   
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
   
   func removeAllMushrooms() {
      for node in children {
         if node.isMushroom() {
            node.removeFromParent()
         }
      }
   }
   
   /// \ref issue54 \ref issue56 \ref issue57
   func healMushrooms(inSequence : ArraySlice<SKNode>) {
      if 0 < inSequence.count {
         shooter.isHidden = true
         let mushroom = inSequence.last as! Mushroom
         mushroom.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), SKAction.run {
            mushroom.heal()
            self.incrementScore(1) // \ref issue56
            mushroom.run(GameScene.healAudioAction)
            if 1 < inSequence.count {
               self.healMushrooms(inSequence: inSequence[..<(inSequence.count - 1)])
            } else {
                self.shooter.isHidden = false
            }
         }]))
      }
   }
   
   /// \ref issue54
   func healDamagedMushrooms() {
      let mushroomChildren : [SKNode] = children.filter({ (node : SKNode) in
         return node.isMushroom() && (0 != (node as! Mushroom).state)
      })
      healMushrooms(inSequence: mushroomChildren[...])
   }
   
   /// \ref issue54 \ref issue87
   func processEndOfLevel() {
      healDamagedMushrooms()
      Centipede.periodBetweenMoves *= 0.9 // Each level centipede is faster
   }
   
   /// \ref issue54
   func registerCentipede(_ centipede: Centipede) {
      centipedes.insert(centipede)
   }
   
   /// \ref issue54
   func unregisterCentipede(_ centipede: Centipede) {
      centipedes.remove(centipede)
      if 0 == centipedes.count {
         processEndOfLevel()
      }
   }
   
   func removeAllCentipedes() {
      for centipede in centipedes {
         centipede.removeAllSegements()
      }
      centipedes.removeAll()
   }

   /// \ref issue57
   func spawnNewCentipede() {
      let centipede = Centipede()
      centipede.addSegments(number: GameScene.defaultCentipedeSegementsNumber, scene: self)
      centipede.moveHead(scene: self)
      registerCentipede(centipede)
   }
   
   /// \ref issue20
   func spawnShooter() {
      addChild(shooter)
      shooter.position = CGPoint(x: frame.midX, y: 60) //<- Arbitrary start height
      shooter.isHidden = false
   }
   
   /// \ref issue29
   func spawnBullet() {
      bullet.isHidden = true
      addChild(bullet)
   }
   /// \ref issue26 \ref issue27
   func killShooter() {
      if 0 < livesRemainingNumber {
         livesRemainingNumber -= 1
         healDamagedMushrooms()
      } else {
         showGameOverIndicator()
         shooter.isHidden = true
         isGameOver = true
      }
   }
   
   /// \ref issue21 \ref issue23
   func moveShooter(position: CGPoint) {
      if isGameOver {
         startGame()
      }
      if shooter.isHidden == false {
         let maxY = min(position.y, convertGAYToSceneY(gaY: GameScene.playAreaStartGAY))
         let collideNodes = nodes(at: position).filter { (node : SKNode) in
            node !== self && node !== shooter && node !== bullet
         }
         if 0 == collideNodes.count {
            shooter.position = CGPoint(x: position.x, y: maxY)
         } else {
         }
         if bullet.isHidden {
            bullet.position = shooter.position
            bullet.isHidden = false
            self.run(GameScene.shootAudioAction)
         }
      }
   }
   
   /// \ref issue3
   func incrementScore(_ amount: Int) {
      score += amount
   }
   
   /// \ref issue23  \ref issue27
   func processShooterCollisions() {
      let dangerousCollisions = nodes(at: shooter.position).filter { (node: SKNode) in
         node !== self && node !== shooter && node !== bullet &&
         !node.isMushroom()
      }
      if 0 != dangerousCollisions.count {
         killShooter()
         for node in dangerousCollisions {
            node.takeDamage(inScene: self)
         }
      }
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
   
   func hideGameOverIndicator() {
      gameOverIndicator!.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.removeFromParent()]))
   }
   
   func showGameOverIndicator() {
      self.addChild(gameOverIndicator!)
      gameOverIndicator!.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.5)]))
   }

   func spawnGameNodes() {
      spawnNewCentipede()
      spawnMushrooms(number: GameScene.defaultMushroomsNumber)
      spawnBullet()
   }
   
   func startGame() {
      score = 0
      removeAllCentipedes()
      removeAllMushrooms()
      livesRemainingNumber = GameScene.initialLivesRemainingNumber
      shooter.removeFromParent()
      bullet.removeFromParent()
      isGameOver = false
      
      hideGameOverIndicator()
      spawnGameNodes()
      spawnShooter()
   }
   
   /// \ref issue14 \ref issue16 \ref issue20
   override func didMove(to view: SKView) {
      gameOverIndicator = self.childNode(withName: "GameOver")!
      gameOverIndicator!.position = CGPoint(x: 0.5 * frame.width, y: 0.6 * frame.height)
      spawnGameNodes()
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
      if !shooter.isHidden {
         processShooterCollisions()
      }
   }
}
