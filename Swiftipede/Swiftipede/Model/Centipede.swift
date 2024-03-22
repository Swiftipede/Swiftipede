import SpriteKit

class Centipede {
   var piriodBetweenMoves = TimeInterval(0.25)
   let head = SKNode()
   
   var headDestinationGAX = Int32(0)
   var headDestinationGAY = Int32(2)
   var xDirection = Int32(1)
   var yDirection = Int32(-1)

   func moveHead(scene : GameScene) {
      if nil == head.parent {
         scene.addChild(head)
         let segment = GameScene.makeCentipedeHeadSegment()
         segment.position = CGPoint(x: 0, y: 0)
         head.addChild(segment)
         head.position = scene.convertGAtoScene(gaX: headDestinationGAX, gaY: headDestinationGAY)
      }
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
