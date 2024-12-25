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
   
   /// \ref issue39
   @IBOutlet var remainingLifeIndicator0 : UIImageView?
   
   /// \ref issue39
   @IBOutlet var remainingLifeIndicator1 : UIImageView?
   
   /// \ref issue39
   @IBOutlet var remainingLifeIndicator2 : UIImageView?
   
   /// \ref issue39
   @IBOutlet var remainingLifeIndicator3 : UIImageView?
   
   /// \ref issue39
   @IBOutlet var remainingLifeIndicator4 : UIImageView?

   /// \ref issue3
   @objc var gameScene : GameScene?

   /// \ref issue3
   var scoreObservation: NSKeyValueObservation?

   /// \ref issue26 \ref issue39
   var livesObservation: NSKeyValueObservation?

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
      
      /// \ref issue26 \ref issue39
      livesObservation = observe(
          \.gameScene!.livesRemainingNumber,
          options: [.new]
      ) { object, change in
         self.remainingLifeIndicator4?.isHidden = (4 >= change.newValue!)
         self.remainingLifeIndicator3?.isHidden = (3 >= change.newValue!)
         self.remainingLifeIndicator2?.isHidden = (2 >= change.newValue!)
         self.remainingLifeIndicator1?.isHidden = (1 >= change.newValue!)
         self.remainingLifeIndicator0?.isHidden = (0 >= change.newValue!)
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
