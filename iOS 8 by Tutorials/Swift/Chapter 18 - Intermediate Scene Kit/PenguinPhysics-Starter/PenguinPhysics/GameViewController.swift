//
//  GameViewController.swift
//  PenguinPhysics
//
//  Created by Jake Gundersen on 7/23/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
  
  @IBOutlet var scnView: SCNView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  override func shouldAutorotate() -> Bool {
    return true
  }
  
  override func supportedInterfaceOrientations() -> Int {
      return Int(UIInterfaceOrientationMask.Landscape.rawValue)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
}
