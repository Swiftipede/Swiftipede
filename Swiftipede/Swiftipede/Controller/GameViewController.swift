//
//  GameViewController.swift
//  Swiftipede
//
//  Created by Erik M. Buck on 3/17/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
   @IBOutlet var gameView : SKView?
   
   /// \ref issue3 \ref issue25
   @IBOutlet var scoreLabel : UILabel?
   
   /// \ref issue3
   @objc var gameScene : GameScene?

   /// \ref issue3
   var scoreObservation: NSKeyValueObservation?

   /// \ref issue3
   override func viewDidLoad() {
      super.viewDidLoad()
      
      gameScene = gameView!.scene as? GameScene
      
      /// \ref issue3 \ref issue25 \ref issue40
      scoreObservation = observe(
          \.gameScene!.score,
          options: [.new]
      ) { object, change in
         self.scoreLabel!.text = "\(change.newValue!)"
      }
  }
   
   /// \ref issue21
   @IBAction func moveShooter(recognizer: UIPanGestureRecognizer) {
      let viewPosition = recognizer.location(in: gameView!)
      let scenePosition = gameScene!.convertPoint(fromView: viewPosition)
      gameScene!.moveShooter(position: scenePosition)
   }
   
   override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
      if UIDevice.current.userInterfaceIdiom == .phone {
         return .allButUpsideDown
      } else {
         return .all
      }
   }
   
   override var prefersStatusBarHidden: Bool {
      return true
   }
}
