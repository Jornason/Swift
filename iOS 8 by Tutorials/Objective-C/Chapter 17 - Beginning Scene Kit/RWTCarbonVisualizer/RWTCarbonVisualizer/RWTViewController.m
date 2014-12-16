/*
 * Copyright (c) 2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "RWTViewController.h"
#import <SceneKit/SceneKit.h>
#import "RWTAtoms.h"
#import "RWTMolecules.h"

@interface RWTViewController ()

// UI
@property (weak, nonatomic) IBOutlet UILabel *geometryLabel;
@property (weak, nonatomic) IBOutlet SCNView *sceneView;

// Geometry
@property (strong, nonatomic) SCNNode *geometryNode;

// Gestures
@property (assign, nonatomic) float currentAngle;

@end

@implementation RWTViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self sceneSetup];
  self.geometryLabel.text = @"Atoms\n ";
  self.geometryNode = [RWTAtoms allAtoms];
  [self.sceneView.scene.rootNode addChildNode:self.geometryNode];
}

#pragma mark - Scene

- (void)sceneSetup {
  SCNScene *scene = [SCNScene scene];
  
  SCNNode *ambientLightNode = [SCNNode node];
  ambientLightNode.light = [SCNLight light];
  ambientLightNode.light.type = SCNLightTypeAmbient;
  ambientLightNode.light.color = [UIColor colorWithWhite:0.67 alpha:1.0];
  [scene.rootNode addChildNode:ambientLightNode];
  
  SCNNode *omniLightNode = [SCNNode node];
  omniLightNode.light = [SCNLight light];
  omniLightNode.light.type = SCNLightTypeOmni;
  omniLightNode.light.color = [UIColor colorWithWhite:0.75 alpha:1.0];
  omniLightNode.position = SCNVector3Make(0, 50, 50);
  [scene.rootNode addChildNode:omniLightNode];
  
  SCNNode *cameraNode = [SCNNode node];
  cameraNode.camera = [SCNCamera camera];
  cameraNode.position = SCNVector3Make(0, 0, 25);
  [scene.rootNode addChildNode:cameraNode];
  
  UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
  [self.sceneView addGestureRecognizer:panRecognizer];
  
  self.sceneView.scene = scene;
}

- (void)panGesture:(UIPanGestureRecognizer *)sender {
  
  CGPoint translation = [sender translationInView:sender.view];
  float newAngle = translation.x*(M_PI/180);
  newAngle += self.currentAngle;
  
  self.geometryNode.transform = SCNMatrix4MakeRotation(newAngle,0,1,0);
  
  if(sender.state == UIGestureRecognizerStateEnded) {
    self.currentAngle = newAngle;
  }
}

#pragma mark - IBActions

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
  [self.geometryNode removeFromParentNode];
  self.currentAngle = 0.0;
  
  switch(sender.selectedSegmentIndex) {
    case 0: {
      self.geometryLabel.text = @"Atoms\n ";
      self.geometryNode = [RWTAtoms allAtoms];
      break;
    }
    case 1: {
      self.geometryLabel.text = @"Methane\n(Natural Gas)";
      self.geometryNode = [RWTMolecules methaneMolecule];
      break;
    }
    case 2: {
      self.geometryLabel.text = @"Ethanol\n(Alcohol)";
      self.geometryNode = [RWTMolecules ethanolMolecule];
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
  
  [self.sceneView.scene.rootNode addChildNode:self.geometryNode];
}

#pragma mark - Style

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Transition

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  
  [self.sceneView stop:nil];
  [self.sceneView play:nil];
}

@end
