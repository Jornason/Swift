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

#import "RWTMolecules.h"
#import <SceneKit/SceneKit.h>
#import "RWTAtoms.h"

@implementation RWTMolecules

+ (SCNNode *)methaneMolecule {
  SCNNode *methaneMolecule = [SCNNode node];
  
  // 1 Carbon
  SCNNode *carbonNode1 = [self nodeWithAtom:[RWTAtoms carbonAtom] molecule:methaneMolecule position:SCNVector3Make(0,0,0)];
  
  // 4 Hydrogen
  SCNNode *hydrogenNode1 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:methaneMolecule position:SCNVector3Make(-4,0,0)];
  SCNNode *hydrogenNode2 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:methaneMolecule position:SCNVector3Make(+4,0,0)];
  SCNNode *hydrogenNode3 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:methaneMolecule position:SCNVector3Make(0,-4,0)];
  SCNNode *hydrogenNode4 = [self nodeWithAtom:[RWTAtoms hydrogenAtom] molecule:methaneMolecule position:SCNVector3Make(0,+4,0)];
  
  // Add bonds
  [methaneMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode1]];
  [methaneMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode2]];
  [methaneMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode3]];
  [methaneMolecule addChildNode:[self lineBetweenNodeA:carbonNode1 nodeB:hydrogenNode4]];
  
  return methaneMolecule;
}

+ (SCNNode *)ethanolMolecule {
  SCNNode *ethanolMolecule = [SCNNode node];
  
  SCNScene *scene = [SCNScene sceneNamed:@"EthanolScene"];
  for(SCNNode *child in scene.rootNode.childNodes) {
    [ethanolMolecule addChildNode:child];
  }
  
  return [ethanolMolecule flattenedClone];
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

+ (SCNNode *)nodeWithAtom:(SCNGeometry *)atom molecule:(SCNNode *)molecule position:(SCNVector3)position
{
  SCNNode *node = [SCNNode nodeWithGeometry:atom];
  node.position = position;
  [molecule addChildNode:node];
  return node;
}

+ (SCNNode *)lineBetweenNodeA:(SCNNode *)nodeA nodeB:(SCNNode *)nodeB {
  // Positions
  Float32 positions[] = {nodeA.position.x, nodeA.position.y, nodeA.position.z, nodeB.position.x, nodeB.position.y, nodeB.position.z};
  NSData* positionData = [NSData dataWithBytes:positions length:sizeof(positions)];
  
  // Indices
  int32_t indices[] = {0, 1};
  NSData* indexData = [NSData dataWithBytes:indices length:sizeof(indices)];
  
  // SCNGeometry
  SCNGeometrySource* source = [SCNGeometrySource geometrySourceWithData:positionData semantic:SCNGeometrySourceSemanticVertex vectorCount:2 floatComponents:YES componentsPerVector:3 bytesPerComponent:sizeof(Float32) dataOffset:0 dataStride:sizeof(Float32)*3];
  SCNGeometryElement* element = [SCNGeometryElement geometryElementWithData:indexData primitiveType:SCNGeometryPrimitiveTypeLine primitiveCount:2 bytesPerIndex:sizeof(int32_t)];
  
  // Line
  SCNGeometry* line = [SCNGeometry geometryWithSources:@[source] elements:@[element]];
  return [SCNNode nodeWithGeometry:line];
}

@end
