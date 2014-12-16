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

class ColorPaletterProvider {
  
  var rootCollection: ColorPaletteCollection?
  
  init(plistName: String) {
    rootCollection = parsePlistWithName(plistName)
  }
  
  convenience init() {
    self.init(plistName: "DefaultColourSwatchCollection")
  }
  
  
  // Private methods
  private func parsePlistWithName(name: String) -> ColorPaletteCollection {
    let plistRoot = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource(name, ofType: "plist")!)
    let parsedItems = parseArrayIntoTreeItems(plistRoot as [NSDictionary])
    return ColorPaletteCollection(name: "root", children: parsedItems)
  }
  
  private func parseArrayIntoTreeItems(array: [NSDictionary]) -> [PaletteTreeNode] {
    var parsedItems = [PaletteTreeNode]()
    for dict in array {
      let parsedDict = parseDictionaryIntoTreeItem(dict)
      parsedItems.append(parsedDict)
    } 
    return parsedItems
  }
  
  private func parseDictionaryIntoTreeItem(dict: NSDictionary) -> PaletteTreeNode {
    let name = dict["name"] as String
    if (dict["children"] != nil) {
      let parsedChildren = parseArrayIntoTreeItems(dict["children"] as [NSDictionary])
      return ColorPaletteCollection(name: name, children: parsedChildren)
    } else if (dict["colors"] != nil) {
      var colorScheme = [UIColor]()
      for hexString in dict["colors"] as [String] {
        colorScheme.append(UIColor(fromHexString: hexString))
      }
      return ColorPalette(name: name, colors: colorScheme)
    } else {
      let baseColor = UIColor(fromHexString: dict["color"] as String)
      var scheme = baseColor.colorSchemeOfType(.Analagous) as [UIColor]
      scheme.insert(baseColor, atIndex: 2)
      return ColorPalette(name: name, colors: scheme)
    }
  }
  
}