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

class GameViewController: UIViewController, SCNSceneRendererDelegate {
  
  @IBOutlet var scnView: SCNView!
  let scene = SCNScene(named: "SceneIceRotated.dae")!
  let snow = SCNParticleSystem(named: "Snow", inDirectory: nil)
  
  var applyForce = false
  var force:Float = 50.0
  
  let cube:SCNNode
  let slopeNode:SCNNode
  
  var sliderJoint:SCNPhysicsSliderJoint!
  
  required init(coder aDecoder: NSCoder) {
    cube = scene.rootNode.childNodeWithName("Cube", recursively: false)!
    slopeNode = SCNNode()
    
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scnView.scene = scene
    scnView.allowsCameraControl = true
    scnView.showsStatistics = true
    scnView.delegate = self
    
    scene.physicsWorld.gravity = SCNVector3Make(0.0, -9.8, 0.0);
    
    cube.physicsBody = SCNPhysicsBody.dynamicBody()
    
    cube.physicsBody!.mass = 5.0
    cube.physicsBody!.restitution = 0.01
    
    if let slope = scene.rootNode.childNodeWithName("Slope", recursively: false) {
        slope.physicsBody = SCNPhysicsBody.kinematicBody()
        slopeNode.pivot = SCNMatrix4MakeTranslation(-7.0, 0.0, 0.0)
        slopeNode.position = SCNVector3Make(-7.0, 0.0, 0.0)
        slopeNode.addChildNode(slope)
        scene.rootNode.addChildNode(slopeNode)
        
        
        //1
        sliderJoint = SCNPhysicsSliderJoint(bodyA: cube.physicsBody, axisA: SCNVector3Make(0.0, -1.0, 0.0), anchorA: SCNVector3Make(0.0, 0.0, -1.0), bodyB: slope.physicsBody, axisB: SCNVector3Make(0.0, -1.0, 0.0), anchorB: SCNVector3Make(0.0, 0.0, -0.20))
        //2
        sliderJoint.maximumLinearLimit = 4.0
        sliderJoint.minimumLinearLimit = -5.5
        //3
        sliderJoint.maximumAngularLimit = 0.0
        sliderJoint.minimumAngularLimit = 0.0
        //4
        scene.physicsWorld.addBehavior(sliderJoint)
        
        cube.physicsBody!.categoryBitMask = 1
        cube.physicsBody!.collisionBitMask = 1
        slope.physicsBody!.categoryBitMask = 2
        slope.physicsBody!.collisionBitMask = 2
    }
    let particleEmitterNode = SCNNode()
    particleEmitterNode.addParticleSystem(snow)
    particleEmitterNode.position = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
    scene.rootNode.addChildNode(particleEmitterNode)
  }
  
  override func shouldAutorotate() -> Bool {
    return true
  }
  
  @IBAction func applyForceTapped(sender: AnyObject) {
    let button = sender as UIButton
    if (applyForce) {
      button.setTitle("Apply Force", forState: .Normal)
      applyForce = false
    } else {
      button.setTitle("Stop", forState: .Normal)
      applyForce = true
    }
  }
  
  @IBAction func angleSliderMoved(sender: AnyObject) {
    var angle:Float = (1.0 - sender.value) * Float(M_PI_4)
    slopeNode.eulerAngles = SCNVector3Make(0.0, 0.0, angle)
  }
  
  @IBAction func forceSliderMoved(sender: AnyObject) {
    force = sender.value * 300.0
  }
  
  func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
    if applyForce {
      cube.physicsBody!.applyForce(SCNVector3Make(force, 0.0, 0.0), impulse: false)
    }
  }
  
  override func supportedInterfaceOrientations() -> Int {
      return Int(UIInterfaceOrientationMask.Landscape.rawValue)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
}
