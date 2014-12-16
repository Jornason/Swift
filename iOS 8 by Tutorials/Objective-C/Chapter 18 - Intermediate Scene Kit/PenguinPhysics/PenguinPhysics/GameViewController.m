//
//  GameViewController.m
//  PenguinPhysics
//
//  Created by Jake Gundersen on 7/25/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController() <SCNSceneRendererDelegate>

@property (strong, nonatomic) IBOutlet SCNView *scnView;
@property (nonatomic, strong) SCNScene *scene;

@property (nonatomic, strong) SCNParticleSystem *snow;

@property (nonatomic, assign) BOOL applyForce;

@property (nonatomic, assign) float force;

@property (nonatomic, strong) SCNNode *cube;
@property (nonatomic, strong) SCNNode *rampNode;

@property (nonatomic, strong) SCNPhysicsSliderJoint *sliderJoint;

@end

@implementation GameViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.scene = [SCNScene sceneNamed:@"SceneIceRotated"];
  self.scnView.scene = self.scene;
  self.scnView.allowsCameraControl = YES;
  self.scnView.showsStatistics = YES;
  self.scnView.delegate = self;
  
  self.scene.physicsWorld.gravity = SCNVector3Make(0.0, -9.8, 0.0);
  
  self.cube = [self.scene.rootNode childNodeWithName:@"Cube" recursively:NO];
  self.cube.physicsBody = [SCNPhysicsBody dynamicBody];
  self.cube.physicsBody.mass = 5.0;
  self.cube.physicsBody.restitution = 0.01;
  
  SCNNode *ramp = [self.scene.rootNode childNodeWithName:@"Slope" recursively:NO];
  ramp.physicsBody = [SCNPhysicsBody kinematicBody];
  self.rampNode = [SCNNode node];
  [self.rampNode addChildNode:ramp];
  [self.scene.rootNode addChildNode:self.rampNode];
  self.rampNode.pivot = SCNMatrix4MakeTranslation(-7.0, 0.0, 0.0);
  self.rampNode.position = SCNVector3Make(-7.0, 0.0, 0.0);
  
  self.sliderJoint = [SCNPhysicsSliderJoint jointWithBodyA:self.cube.physicsBody axisA:SCNVector3Make(0.0, -1.0, 0.0) anchorA:SCNVector3Make(0.0, 0.0, -1.0) bodyB:ramp.physicsBody axisB:SCNVector3Make(0.0, -1.0, 0.0) anchorB:SCNVector3Make(0.0, 0.0, -0.20)];
  self.sliderJoint.maximumLinearLimit = 4.0;
  self.sliderJoint.minimumLinearLimit = -5.5;
  self.sliderJoint.minimumAngularLimit = 0.0;
  self.sliderJoint.maximumAngularLimit = 0.0;
  
  [self.scene.physicsWorld addBehavior:self.sliderJoint];
  
  self.cube.physicsBody.categoryBitMask = 1;
  self.cube.physicsBody.collisionBitMask = 1;
  ramp.physicsBody.categoryBitMask = 2;
  ramp.physicsBody.collisionBitMask = 2;
  
  SCNParticleSystem *snow = [SCNParticleSystem particleSystemNamed:@"Snow" inDirectory:nil];
  SCNNode *particleEmitterNode = [SCNNode node];
  particleEmitterNode.position = SCNVector3Make(0.0, 10.0, 0.0);
  [particleEmitterNode addParticleSystem:snow];
}

- (IBAction)applyForceTapped:(id)sender {
  UIButton *button = (UIButton *)sender;
  if (self.applyForce) {
    [button setTitle:@"Apply Force" forState:UIControlStateNormal];
    self.applyForce = NO;
  } else {
    [button setTitle:@"Stop" forState:UIControlStateNormal];
    self.applyForce = YES;
  }
}

- (IBAction)forceSliderMoved:(id)sender {
  UISlider *slider = (UISlider *)sender;
  self.force = slider.value * 300.0;
}

- (IBAction)angleSliderMoved:(id)sender {
  UISlider *slider = (UISlider *)sender;
  float angle = (1.0 - slider.value) * M_PI_4;
  self.rampNode.eulerAngles = SCNVector3Make(0.0, 0.0, angle);
}

- (void)renderer:(id<SCNSceneRenderer>)aRenderer updateAtTime:(NSTimeInterval)time {
  if (self.applyForce) {
    [self.cube.physicsBody applyForce:SCNVector3Make(self.force, 0.0, 0.0) impulse:NO];
  }
}


- (BOOL)shouldAutorotate
{
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskAllButUpsideDown;
  } else {
    return UIInterfaceOrientationMaskAll;
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

@end
