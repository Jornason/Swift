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

import Foundation
import SceneKit

class Molecules {
  class func methaneMolecule() -> SCNNode {
    var methaneMolecule = SCNNode()
    
    // 1 Carbon
    let carbonNode1 = nodeWithAtom(Atoms.carbonAtom(), molecule: methaneMolecule, position: SCNVector3Make(0, 0, 0))
    
    // 4 Hydrogen
    let hydrogenNode1 = nodeWithAtom(Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(-4, 0, 0))
    let hydrogenNode2 = nodeWithAtom(Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(+4, 0, 0))
    let hydrogenNode3 = nodeWithAtom(Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(0, -4, 0))
    let hydrogenNode4 = nodeWithAtom(Atoms.hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(0, +4, 0))
    
    // Bonds
    methaneMolecule.addChildNode(lineBetweenNodeA(carbonNode1, nodeB: hydrogenNode1))
    methaneMolecule.addChildNode(lineBetweenNodeA(carbonNode1, nodeB: hydrogenNode2))
    methaneMolecule.addChildNode(lineBetweenNodeA(carbonNode1, nodeB: hydrogenNode3))
    methaneMolecule.addChildNode(lineBetweenNodeA(carbonNode1, nodeB: hydrogenNode4))
    
    return methaneMolecule
  }
  
  class func ethanolMolecule() -> SCNNode {
    var ethanolMolecule = SCNNode()
    
    let scene = SCNScene(named: "EthanolScene")!
    for child : AnyObject in scene.rootNode.childNodes {
      ethanolMolecule.addChildNode(child as SCNNode)
    }
    
    return ethanolMolecule
  }
  
  class func ptfeMolecule() -> SCNNode {
    var ptfeMolecule = SCNNode()
    
    var carbonNode2Previous: SCNNode?
    for i in -1...1 {
      let fi = Float(i)
      
      // 2 Carbon
      let carbonNode1 = nodeWithAtom(Atoms.carbonAtom(), molecule: ptfeMolecule, position: SCNVector3Make(-2+(fi*8), +2, 0))
      let carbonNode2 = nodeWithAtom(Atoms.carbonAtom(), molecule: ptfeMolecule, position: SCNVector3Make(+2+(fi*8), -2, 0))
      
      // 4 Fluorine
      let fluorineNode1 = nodeWithAtom(Atoms.fluorineAtom(), molecule: ptfeMolecule, position: SCNVector3Make(-2+(fi*8), -4, +2))
      let fluorineNode2 = nodeWithAtom(Atoms.fluorineAtom(), molecule: ptfeMolecule, position: SCNVector3Make(-2+(fi*8), -4, -2))
      let fluorineNode3 = nodeWithAtom(Atoms.fluorineAtom(), molecule: ptfeMolecule, position: SCNVector3Make(+2+(fi*8), +4, +2))
      let fluorineNode4 = nodeWithAtom(Atoms.fluorineAtom(), molecule: ptfeMolecule, position: SCNVector3Make(+2+(fi*8), +4, -2))
      
      // Bonds
      ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNode1, nodeB: carbonNode2))
      ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNode1, nodeB: fluorineNode1))
      ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNode1, nodeB: fluorineNode2))
      ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNode2, nodeB: fluorineNode3))
      ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNode2, nodeB: fluorineNode4))
      
      if(carbonNode2Previous != nil) {
        ptfeMolecule.addChildNode(lineBetweenNodeA(carbonNode1, nodeB: carbonNode2Previous!))
      }
      carbonNode2Previous = (carbonNode2.copy() as SCNNode)
    }
    
    return ptfeMolecule
  }
  
  class func nodeWithAtom(atom: SCNGeometry, molecule: SCNNode, position: SCNVector3) -> SCNNode {
    let node = SCNNode(geometry: atom)
    node.position = position
    molecule.addChildNode(node)
    return node
  }
  
  class func lineBetweenNodeA(nodeA: SCNNode, nodeB: SCNNode) -> SCNNode {
    // Positions
    let positions: [Float32] = [nodeA.position.x, nodeA.position.y, nodeA.position.z, nodeB.position.x, nodeB.position.y, nodeB.position.z]
    let positionData = NSData(bytes: positions, length: sizeof(Float32)*positions.count)
    
    // Indices
    let indices: [Int32] = [0, 1]
    let indexData = NSData(bytes: indices, length: sizeof(Int32)*indices.count)
    
    // SCNGeometry
    let source = SCNGeometrySource(data: positionData, semantic: SCNGeometrySourceSemanticVertex, vectorCount: indices.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(Float32), dataOffset: 0, dataStride: sizeof(Float32)*3)
    let element = SCNGeometryElement(data: indexData, primitiveType: SCNGeometryPrimitiveType.Line, primitiveCount: indices.count, bytesPerIndex: sizeof(Int32))
    
    // Line
    let line = SCNGeometry(sources: [source], elements: [element])
    return SCNNode(geometry: line)
  }
}
