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


import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
  }
  
  
  // MARK:- UISplitViewControllerDelegate
  func splitViewController(splitController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
    if let selectionCont = primaryViewController as? PaletteSelectionContainer {
      if let displayCont = secondaryViewController as? PaletteDisplayContainer {
        let selectedPalette = selectionCont.rwt_currentlySelectedPalette()
        let displayedPalette = displayCont.rwt_currentlyDisplayedPalette()
        if selectedPalette? != nil && selectedPalette == displayedPalette {
          return false
        }
      }
    }
    // We don't want anything to happen. Say we've dealt with it
    return true
  }
  
  func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController!) -> UIViewController? {
    if let paletteDisplayCont = primaryViewController as? PaletteDisplayContainer {
      if paletteDisplayCont.rwt_currentlyDisplayedPalette() != nil{
        return nil
      }
    }
    let vc = storyboard?.instantiateViewControllerWithIdentifier("NoPaletteSelected") as UIViewController
    return NavigationController(rootViewController: vc)
  }
}
