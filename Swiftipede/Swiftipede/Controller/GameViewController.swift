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
