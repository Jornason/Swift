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

#import "RWTAtoms.h"
#import <SceneKit/SceneKit.h>

@implementation RWTAtoms

+ (SCNGeometry *)carbonAtom {
  SCNSphere *carbonAtom = [SCNSphere sphereWithRadius:1.70];
  carbonAtom.firstMaterial.diffuse.contents = [UIColor darkGrayColor];
  carbonAtom.firstMaterial.specular.contents = [UIColor whiteColor];
  return carbonAtom;
}

+ (SCNGeometry *)hydrogenAtom {
  SCNSphere *hydrogenAtom = [SCNSphere sphereWithRadius:1.20];
  hydrogenAtom.firstMaterial.diffuse.contents = [UIColor lightGrayColor];
  hydrogenAtom.firstMaterial.specular.contents = [UIColor whiteColor];
  return hydrogenAtom;
}

+ (SCNGeometry *)oxygenAtom {
  SCNSphere *oxygenAtom = [SCNSphere sphereWithRadius:1.52];
  oxygenAtom.firstMaterial.diffuse.contents = [UIColor redColor];
  oxygenAtom.firstMaterial.specular.contents = [UIColor whiteColor];
  return oxygenAtom;
}

+ (SCNGeometry *)fluorineAtom {
  SCNSphere *fluorineAtom = [SCNSphere sphereWithRadius:1.47];
  fluorineAtom.firstMaterial.diffuse.contents = [UIColor yellowColor];
  fluorineAtom.firstMaterial.specular.contents = [UIColor whiteColor];
  return fluorineAtom;
}

+ (SCNNode *)allAtoms {
  SCNNode *atomsNode = [SCNNode node];
  
  SCNNode *carbonNode = [SCNNode nodeWithGeometry:[RWTAtoms carbonAtom]];
  carbonNode.position = SCNVector3Make(-6,0,0);
  [atomsNode addChildNode:carbonNode];
  
  SCNNode *hydrogenNode = [SCNNode nodeWithGeometry:[RWTAtoms hydrogenAtom]];
  hydrogenNode.position = SCNVector3Make(-2,0,0);
  [atomsNode addChildNode:hydrogenNode];
  
  SCNNode *oxygenNode = [SCNNode nodeWithGeometry:[RWTAtoms oxygenAtom]];
  oxygenNode.position = SCNVector3Make(+2,0,0);
  [atomsNode addChildNode:oxygenNode];
  
  SCNNode *fluorineNode = [SCNNode nodeWithGeometry:[RWTAtoms fluorineAtom]];
  fluorineNode.position = SCNVector3Make(+6,0,0);
  [atomsNode addChildNode:fluorineNode];
  
  return atomsNode;
}

@end
