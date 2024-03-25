import SpriteKit

class CentipedeSegment : SKNode {
   var segmentImage = GameScene.makeCentipedeBodySegment()
   
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
}

class Centipede {
   var piriodBetweenMoves = TimeInterval(0.25)
   var segements = [CentipedeSegment]()
   
   var headDestinationGAX = Int32(-1)
   var headDestinationGAY = Int32(39)
   var xDirection = Int32(1)
   var yDirection = Int32(-1)
   
   func addSegments(number : Int32, scene: GameScene) {
      for _ in 0..<number {
         let newSegment = CentipedeSegment()
         newSegment.becomeBody()
         segements.append(newSegment)
         scene.addChild(newSegment)
         newSegment.position = scene.convertGAtoScene(gaX: headDestinationGAX, gaY: headDestinationGAY)
      }
      if 0 < segements.count {
         segements[0].becomeHead()
         if 1 < segements.count { segements[segements.count - 1].becomeTail() }
      }
   }
   
   func hasCollisions(gaX: Int32, gaY: Int32, scene: GameScene) -> Bool {
      let candidatePosition = scene.convertGAtoScene(gaX: gaX, gaY: gaY)
      let collideNodes = scene.nodes(at: candidatePosition).filter { (node : SKNode) in
         node !== scene
      }
      return 0 < collideNodes.count
   }
   
   func moveHead(scene : GameScene) {
      if 0 < segements.count {
         for index in (1..<segements.count).reversed() {
            let currentSegment = segements[index]
            let predecesorSegment = segements[index - 1]
            let destination = predecesorSegment.position
            currentSegment.xScale = (destination.x > currentSegment.position.x) ? 1 : -1
            currentSegment.run(SKAction.move(to: destination, duration: piriodBetweenMoves))
         }
         
         let head = segements[0]
         headDestinationGAX += xDirection
         if headDestinationGAX >= GameScene.gameAreaWidth || headDestinationGAX < 0 || 
               hasCollisions(gaX: headDestinationGAX, gaY: headDestinationGAY, scene: scene) {
            headDestinationGAY += yDirection
            if headDestinationGAY >= GameScene.gameAreaHeight || headDestinationGAY < 0 {
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
