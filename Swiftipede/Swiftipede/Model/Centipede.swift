import SpriteKit

/// \ref issue14
class CentipedeSegment : SKNode {
   var segmentImage = GameScene.makeCentipedeBodySegment()
   var centipede : Centipede?
   
   func becomeBody() {
      if nil != segmentImage.parent { segmentImage.removeFromParent() }
      segmentImage = GameScene.makeCentipedeBodySegment()
      segmentImage.position = CGPoint(x:0, y:0)
      addChild(segmentImage)
   }
   
   func becomeHead() {
      if nil != segmentImage.parent { segmentImage.removeFromParent() }
      segmentImage = GameScene.makeCentipedeHeadSegment()
      segmentImage.position = CGPoint(x:0, y:0)
      addChild(segmentImage)
   }
   
   func becomeTail() {
      if nil != segmentImage.parent { segmentImage.removeFromParent() }
      segmentImage = GameScene.makeCentipedeTailSegment()
      segmentImage.position = CGPoint(x:0, y:0)
      addChild(segmentImage)
   }
   
   /// \ref issue31 \ref issue32
   override func takeDamage(scene : GameScene) {
      segmentImage.removeFromParent()
      if let newCentipede = centipede?.split(atSegment: self, scene: scene) {
         self.removeAllActions()
         newCentipede.moveHead(scene: scene)
      }
      scene.incrementScore(1)
      self.run(GameScene.hitAudioAction)
   }
}

class Centipede : Hashable {
   static func == (lhs: Centipede, rhs: Centipede) -> Bool {
      return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
   }
   
   func hash(into hasher: inout Hasher) {
      hasher.combine(ObjectIdentifier(self))
   }

   /// \ref issue14
   var segments = [CentipedeSegment]()
   
   /// \ref issue18 \ref issue15 \ref issue17 \ref issue87
   static let initialPeriodBetweenMoves = TimeInterval(0.125)
   static var periodBetweenMoves = initialPeriodBetweenMoves
   var headDestinationGAX = Int32(-1)
   var headDestinationGAY = Int32(39)
   var xDirection = Int32(1)
   var yDirection = Int32(-1)
   
   /// \ref issue33 \ref issue34 \ref issue35
   func split(atSegment: CentipedeSegment, scene : GameScene) -> Centipede? {
      var newCentipede : Centipede? = nil
      if let splitIndex = segments.firstIndex(of: atSegment) {
         let orphanSegments = segments[(splitIndex+1)...]
         let remainingSegments = segments[..<splitIndex]
         if 0 < orphanSegments.count {
            newCentipede = Centipede()
            newCentipede!.addSegments(arraySlice: orphanSegments, scene: scene)
            newCentipede!.headDestinationGAX = scene.convertSceneXtoGAX(position: atSegment.position)
            newCentipede!.headDestinationGAY = scene.convertSceneYtoGAY(position: atSegment.position) + yDirection
            newCentipede!.xDirection = -xDirection
            newCentipede!.segments[0].xScale = CGFloat(newCentipede!.xDirection)

            newCentipede!.yDirection = yDirection
            scene.registerCentipede(newCentipede!)
         }
         if 0 < remainingSegments.count {
            segments.removeAll()
            segments.append(contentsOf: remainingSegments)
            if 1 < segments.count { segments[segments.count - 1].becomeTail() }
         } else {
            scene.unregisterCentipede(self)
         }
      }
      return newCentipede
   }
   
   func addSegments(arraySlice: ArraySlice<CentipedeSegment>, scene: GameScene) {
      segments.append(contentsOf: arraySlice)
      if 0 < segments.count {
         segments[0].becomeHead()
         if 1 < segments.count { segments[segments.count - 1].becomeTail() }
      }
      for segment in segments {
         segment.removeAllActions()
         segment.centipede = self
      }
   }
   
   /// \ref issue14
   func addSegments(number : UInt32, scene: GameScene) {
      for _ in 0..<number {
         let newSegment = CentipedeSegment()
         newSegment.centipede = self
         newSegment.becomeBody()
         segments.append(newSegment)
         scene.addChild(newSegment)
         newSegment.position = scene.convertGAtoScene(gaX: headDestinationGAX, gaY: headDestinationGAY)
      }
      if 0 < segments.count {
         segments[0].becomeHead()
         if 1 < segments.count { segments[segments.count - 1].becomeTail() }
      }
   }
   
   func removeAllSegements() {
      for segment in segments {
         segment.removeFromParent()
      }
      segments.removeAll()
   }
   
   /// \ref issue4 \ref issue24 \ref issue30
   func hasCollisions(gaX: Int32, gaY: Int32, scene: GameScene) -> Bool {
      let candidatePosition = scene.convertGAtoScene(gaX: gaX, gaY: gaY)
      let collideNodes = scene.nodes(at: candidatePosition).filter { (node : SKNode) in
         node !== scene && node !== scene.shooter
      }
      return 0 < collideNodes.count
   }
   
   /// \ref issue18 \ref issue15 \ref issue17 \ref issue19
   func moveHead(scene : GameScene) {
      if !scene.centipedes.contains(self) {
         // Centipede may be dead but was retained by lingering run action 
      } else {
         if 0 < segments.count {
            for index in (1..<segments.count).reversed() {
               let currentSegment = segments[index]
               let predecesorSegment = segments[index - 1]
               let destination = predecesorSegment.position
               currentSegment.xScale = (destination.x > currentSegment.position.x) ? 1 : -1
               currentSegment.run(SKAction.move(to: destination, duration: Centipede.periodBetweenMoves))
            }
            
            let head = segments[0]
            headDestinationGAX += xDirection
            if headDestinationGAX >= GameScene.gameAreaWidth || headDestinationGAX < 0 ||
                  hasCollisions(gaX: headDestinationGAX, gaY: headDestinationGAY, scene: scene) {
               headDestinationGAY += yDirection
               if 0 > headDestinationGAY {
                  print("\(headDestinationGAY)")
                  yDirection *= -1
                  headDestinationGAY += yDirection * 2
                  if !scene.shouldSpawnNewCentipedeHeads {
                     scene.shouldSpawnNewCentipedeHeads = true // \ref issue102
                  }
               }
               if 0 < yDirection && headDestinationGAY > GameScene.playAreaStartGAY {
                  /// \ref issue19
                  yDirection *= -1
               }
               xDirection *= -1;
               head.xScale = CGFloat(xDirection)
               headDestinationGAX += xDirection
            }
            let destination = scene.convertGAtoScene(gaX: headDestinationGAX, gaY: headDestinationGAY)
            head.run(SKAction.move(to: destination, duration: Centipede.periodBetweenMoves)) {
               self.moveHead(scene: scene)
            }
         }
      }
   }
}
