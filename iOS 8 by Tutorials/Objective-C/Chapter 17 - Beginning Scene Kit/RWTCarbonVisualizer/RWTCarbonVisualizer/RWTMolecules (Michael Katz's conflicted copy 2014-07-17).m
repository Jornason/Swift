//
//  RWTMolecules.m
//  RWTCarbonVisualizer
//
//  Created by Ricardo on 6/25/14.
//  Copyright (c) 2014 RayWenderlich. All rights reserved.
//

#import "RWTMolecules.h"
#import <SceneKit/SceneKit.h>
#import "RWTAtoms.h"

@implementation RWTMolecules

#pragma mark - Molecules

+ (SCNNode *)methaneMolecule {
  SCNNode *methaneMolecule = [SCNNode node];
  
  // 1 Carbon
  SCNNode *carbonNode1 = [self nodeWithAtom:[RWTAtoms carbonAtom] molecule:methaneMolecule position:SCNVector3Make(0,0,0)];
  
  // 4 Hydrogen
  SCNNode *hydrogenNode1 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:methaneMolecule position:SCNVector3Make(-4,0,0)];
  SCNNode *hydrogenNode2 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:methaneMolecule position:SCNVector3Make(+4,0,0)];
  SCNNode *hydrogenNode3 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:methaneMolecule position:SCNVector3Make(0,-4,0)];
  SCNNode *hydrogenNode4 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:methaneMolecule position:SCNVector3Make(0,+4,0)];
  
  // Flatten geometry
  methaneMolecule = [methaneMolecule flattenedClone];
  
  // Add bonds
  [methaneMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode1]];
  [methaneMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode2]];
  [methaneMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode3]];
  [methaneMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode4]];
  
  return methaneMolecule;
}

+ (SCNNode *)ethanolMolecule {
  SCNNode *ethanolMolecule = [SCNNode node];
  
  // 2 Carbon
  SCNNode *carbonNode1 = [self nodeWithAtom:[RWTAtoms carbonAtom] molecule:ethanolMolecule position:SCNVector3Make(-2,0,0)];
  SCNNode *carbonNode2 = [self nodeWithAtom:[RWTAtoms carbonAtom] molecule:ethanolMolecule position:SCNVector3Make(+2,0,0)];
  
  // 1 Oxygen
  SCNNode *oxygenNode1 = [self nodeWithAtom:[RWTAtoms oxygenAtom] molecule:ethanolMolecule position:SCNVector3Make(+4,+4,0)];
  
  // 6 Hydrogen
  SCNNode *hydrogenNode1 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:ethanolMolecule position:SCNVector3Make(+8,+4,0)];
  SCNNode *hydrogenNode2 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:ethanolMolecule position:SCNVector3Make(+4,-4,+2)];
  SCNNode *hydrogenNode3 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:ethanolMolecule position:SCNVector3Make(-4,+4,+2)];
  SCNNode *hydrogenNode4 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:ethanolMolecule position:SCNVector3Make(-6,-4,0)];
  SCNNode *hydrogenNode5 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:ethanolMolecule position:SCNVector3Make(-4,+4,-2)];
  SCNNode *hydrogenNode6 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:ethanolMolecule position:SCNVector3Make(+4,-4,-2)];
  
  // Flatten geometry
  ethanolMolecule = [ethanolMolecule flattenedClone];
  
  // Add bonds
  [ethanolMolecule addChildNode:[self lineBetweenNodeA:oxygenNode1 nodeB:hydrogenNode1]];
  [ethanolMolecule addChildNode:[self lineBetweenNodeA:carbonNode2 nodeB:oxygenNode1]];
  [ethanolMolecule addChildNode:[self lineBetweenNodeA:carbonNode2 nodeB:hydrogenNode2]];
  [ethanolMolecule addChildNode:[self lineBetweenNodeA:carbonNode2 nodeB:hydrogenNode6]];
  [ethanolMolecule addChildNode:[self lineBetweenNodeA:carbonNode2 nodeB:carbonNode1]];
  [ethanolMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode3]];
  [ethanolMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode4]];
  [ethanolMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode5]];
  
  return ethanolMolecule;
}

+ (SCNNode *)ptfeMolecule {
  SCNNode *ptfeMolecule = [SCNNode node];
  
  SCNNode *carbonNode2Previous;
  for(int i=-1; i<=1; i++) {
    // 2 Carbon
    SCNNode *carbonNode1 = [self nodeWithAtom:[RWTAtoms carbonAtom] molecule:ptfeMolecule position:SCNVector3Make(-2+(i*8),+2,0)];
    SCNNode *carbonNode2 = [self nodeWithAtom:[RWTAtoms carbonAtom] molecule:ptfeMolecule position:SCNVector3Make(+2+(i*8),-2,0)];
    
    // 4 Fluorine
    SCNNode *fluorineNode1 = [self nodeWithAtom:[RWTAtoms fluorineAtom] molecule:ptfeMolecule position:SCNVector3Make(-2+(i*8),-4,+2)];
    SCNNode *fluorineNode2 = [self nodeWithAtom:[RWTAtoms fluorineAtom] molecule:ptfeMolecule position:SCNVector3Make(-2+(i*8),-4,-2)];
    SCNNode *fluorineNode3 = [self nodeWithAtom:[RWTAtoms fluorineAtom] molecule:ptfeMolecule position:SCNVector3Make(+2+(i*8),+4,+2)];
    SCNNode *fluorineNode4 = [self nodeWithAtom:[RWTAtoms fluorineAtom] molecule:ptfeMolecule position:SCNVector3Make(+2+(i*8),+4,-2)];
    
    // Add bonds
    [ptfeMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:carbonNode2]];
    [ptfeMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:fluorineNode1]];
    [ptfeMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:fluorineNode2]];
    [ptfeMolecule addChildNode:[self lineBetweenNodeA:carbonNode2 nodeB:fluorineNode3]];
    [ptfeMolecule addChildNode:[self lineBetweenNodeA:carbonNode2 nodeB:fluorineNode4]];
    if(carbonNode2Previous) {
      [ptfeMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:carbonNode2Previous]];
    }
    carbonNode2Previous = [carbonNode2 copy];
  }
  
  return ptfeMolecule;
}

+ (SCNNode *)ethanolMoleculeFromScene{
  SCNNode *ethanolMolecule = [SCNNode node];
  SCNScene *scene = [SCNScene sceneNamed:@"EthanolScene"];
  for(SCNNode *child in scene.rootNode.childNodes) {
    [ethanolMolecule addChildNode:child];
  }
  return [ethanolMolecule flattenedClone];
}

#pragma mark - Builder

+ (SCNNode *)nodeWithAtom:(SCNGeometry *)atom molecule:(SCNNode *)molecule position:(SCNVector3)position
{
  SCNNode *node = [SCNNode nodeWithGeometry:atom];
  node.position = position;
  [molecule addChildNode:node];
  return node;
}

#pragma mark - Bonds

+ (SCNNode *)lineBetweenNodeA:(SCNNode *)nodeA nodeB:(SCNNode *)nodeB {
  SCNVector3 positions[] = {nodeA.position, nodeB.position};
  int indices[] = {0,1};
  
  SCNGeometrySource *source = [SCNGeometrySource geometrySourceWithVertices:positions count:2];
  NSData *data = [NSData dataWithBytes:indices length:sizeof(indices)];
  SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:data primitiveType:SCNGeometryPrimitiveTypeLine primitiveCount:2 bytesPerIndex:sizeof(int)];
  SCNGeometry *line = [SCNGeometry geometryWithSources:@[source] elements:@[element]];
  
  return [SCNNode nodeWithGeometry:line];
}

@end
