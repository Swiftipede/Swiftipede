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
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   /// \ref issue21
   @IBAction func moveShooter(recognizer: UIPanGestureRecognizer) {
      let scene = gameView!.scene as! GameScene
      let viewPosition = recognizer.location(in: gameView!)
      let scenePosition = scene.convertPoint(fromView: viewPosition)
      scene.moveShooter(position: scenePosition)
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
