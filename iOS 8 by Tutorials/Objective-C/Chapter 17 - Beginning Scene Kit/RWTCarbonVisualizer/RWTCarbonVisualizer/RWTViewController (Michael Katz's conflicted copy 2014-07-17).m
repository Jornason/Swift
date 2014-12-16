//
//  RWTViewController.m
//  RWTCarbonVisualizer
//
//  Created by Ricardo on 6/24/14.
//  Copyright (c) 2014 RayWenderlich. All rights reserved.
//

// Links
// http://en.wikipedia.org/wiki/Methane
// http://en.wikipedia.org/wiki/Carbon_dioxide
// http://en.wikipedia.org/wiki/Polytetrafluoroethylene
// http://en.wikipedia.org/wiki/Van_der_Waals_radius

#import "RWTViewController.h"
#import <SceneKit/SceneKit.h>
#import "RWTAtoms.h"
#import "RWTMolecules.h"

@interface RWTViewController ()

// UI
@property (weak, nonatomic) IBOutlet SCNView *sceneView;
@property (weak, nonatomic) IBOutlet UILabel *geometryLabel;

// Scene
@property (strong, nonatomic) SCNScene *scene;
@property (strong, nonatomic) SCNNode *geometryNode;

// Gestures
@property (assign, nonatomic) float previousAngle;

@end

@implementation RWTViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Scene setup
  [self sceneSetup];
  
  // Add geometry to scene
  self.geometryLabel.text = @"Atoms\n ";
  self.geometryNode = [self atomsShowcase];
  [self.scene.rootNode addChildNode:self.geometryNode];
}

#pragma mark - Scene

- (void)sceneSetup {
  // Create a new scene
  self.scene = [SCNScene scene];
  
  // Create and add a camera to the scene
  SCNNode *cameraNode = [SCNNode node];
  cameraNode.camera = [SCNCamera camera];
  cameraNode.position = SCNVector3Make(0,0,25);
//  cameraNode.camera.usesOrthographicProjection = YES;
//  cameraNode.camera.orthographicScale = 12.5;
  [self.scene.rootNode addChildNode:cameraNode];
  
  // Create and add an ambient light to the scene
  SCNNode *ambientLightNode = [SCNNode node];
  ambientLightNode.light = [SCNLight light];
  ambientLightNode.light.type = SCNLightTypeAmbient;
  ambientLightNode.light.color = [UIColor colorWithWhite:0.67 alpha:1.0];
  [self.scene.rootNode addChildNode:ambientLightNode];
  
  // Create and add an omnidirectional light to the scene
  SCNNode *omniLightNode = [SCNNode node];
  omniLightNode.light = [SCNLight light];
  omniLightNode.light.type = SCNLightTypeOmni;
  omniLightNode.light.color = [UIColor colorWithWhite:0.75 alpha:1.0];
  omniLightNode.position = SCNVector3Make(0,50,50);
  [self.scene.rootNode addChildNode:omniLightNode];
  
  // Set the scene to the view
  self.sceneView.scene = self.scene;
//  self.sceneView.allowsCameraControl = YES;
//  self.sceneView.showsStatistics = YES;
//  self.sceneView.autoenablesDefaultLighting = YES;
}

#pragma mark - Showcase

- (SCNNode *)atomsShowcase {
  SCNNode *geometryNode = [SCNNode node];
  
  SCNNode *carbonNode = [SCNNode nodeWithGeometry:[RWTAtoms carbonAtom]];
  carbonNode.position = SCNVector3Make(-6,0,0);
  [geometryNode addChildNode:carbonNode];
  
  SCNNode *hydrogenNode = [SCNNode nodeWithGeometry:[RWTAtoms hydrogenAtom]];
  hydrogenNode.position = SCNVector3Make(-2,0,0);
  [geometryNode addChildNode:hydrogenNode];
  
  SCNNode *oxygenNode = [SCNNode nodeWithGeometry:[RWTAtoms oxygenAtom]];
  oxygenNode.position = SCNVector3Make(+2,0,0);
  [geometryNode addChildNode:oxygenNode];
  
  SCNNode *fluorineNode = [SCNNode nodeWithGeometry:[RWTAtoms fluorineAtom]];
  fluorineNode.position = SCNVector3Make(+6,0,0);
  [geometryNode addChildNode:fluorineNode];
  
  return [geometryNode flattenedClone];
}

#pragma mark - IBActions

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
  [self.geometryNode removeFromParentNode];
  self.previousAngle = 0;
  switch(sender.selectedSegmentIndex) {
    case 0: {
      self.geometryLabel.text = @"Atoms\n ";
      self.geometryNode = [self atomsShowcase];
      break;
    }
    case 1: {
      self.geometryLabel.text = @"Methane\n(Natural Gas)";
      self.geometryNode = [RWTMolecules methaneMolecule];
      break;
    }
    case 2: {
      self.geometryLabel.text = @"Ethanol\n(Alcohol)";
      self.geometryNode = [RWTMolecules ethanolMoleculeFromScene];
//      self.geometryNode = [RWTMolecules ethanolMolecule];
      break;
    }
    case 3: {
      self.geometryLabel.text = @"Polytetrafluoroethylene\n(Teflon)";
      self.geometryNode = [RWTMolecules ptfeMolecule];
      break;
    }
    default:
      break;
  }
  [self.scene.rootNode addChildNode:self.geometryNode];
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
  
  CGPoint translation = [sender translationInView:sender.view];
  float angle = translation.x*(M_PI/180);
  angle += self.previousAngle;
  
  self.geometryNode.transform = SCNMatrix4MakeRotation(angle,0,1,0);
//  self.geometryNode.rotation = SCNVector4Make(0,1,0,angle);
  
  if(sender.state == UIGestureRecognizerStateEnded) {
    self.previousAngle = angle;
  }
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

@end
