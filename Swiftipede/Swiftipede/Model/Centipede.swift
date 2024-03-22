import SpriteKit

class CentipedeSegment : SKNode {
   var segmentImage = GameScene.makeCentipedeBodySegment()
   
   func becomeBody() {
      addChild(segmentImage)
   }
   
   func becomeHead() {
      segmentImage.removeFromParent()
      segmentImage = GameScene.makeCentipedeHeadSegment()
      segmentImage.position = CGPoint(x:0, y:0)
      addChild(segmentImage)
   }
   
   func becomeTail() {
      segmentImage.removeFromParent()
      segmentImage = GameScene.makeCentipedeTailSegment()
      segmentImage.position = CGPoint(x:0, y:0)
      addChild(segmentImage)
   }
}

class Centipede {
   var piriodBetweenMoves = TimeInterval(0.25)
   var segements = [CentipedeSegment]()
   let head = SKNode()
   
   var headDestinationGAX = Int32(-1)
   var headDestinationGAY = Int32(39)
   var xDirection = Int32(1)
   var yDirection = Int32(-1)
   
   func addSegments(number : Int32, scene: GameScene) {
      for _ in 0..<number {
         let newSegment = CentipedeSegment()
         segements.append(newSegment)
         scene.addChild(newSegment)
         let destination = scene.convertGAtoScene(gaX: headDestinationGAX, gaY: headDestinationGAY)
         newSegment.position = destination
         newSegment.becomeBody()
      }
      let head = segements[0]
      let headDestination = scene.convertGAtoScene(gaX: headDestinationGAX, gaY: headDestinationGAY)
      head.position = headDestination
      head.becomeHead()
      if 1 < number {
         segements[segements.count - 1].becomeTail()
      }
   }
   
   func moveHead(scene : GameScene) {
      if  0 < segements.count {
         for index in (1..<segements.count).reversed() {
            let currentSegment = segements[index]
            let predecesorSegment = segements[index - 1]
            let destination = predecesorSegment.position
            currentSegment.xScale = (destination.x > currentSegment.position.x) ? 1 : -1
            currentSegment.run(SKAction.move(to: destination, duration: piriodBetweenMoves))
         }
         
         let head = segements[0]
         headDestinationGAX += xDirection
         if headDestinationGAX >= GameScene.gameAreaWidth || headDestinationGAX < 0 {
            headDestinationGAY += yDirection
            if headDestinationGAY >= GameScene.gameAreaHeight ||
                  headDestinationGAY < 0 {
               yDirection *= -1
               headDestinationGAY += yDirection * 2
            }
            xDirection *= -1;
            head.xScale = CGFloat(xDirection)
            headDestinationGAX += xDirection
         }
         let destination = scene.convertGAtoScene(gaX: headDestinationGAX, gaY: headDestinationGAY)
         head.run(SKAction.move(to: destination, duration: piriodBetweenMoves)) {
            self.moveHead(scene: scene)
         }
      }
   }
}
