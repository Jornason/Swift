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

/** This is a container view controller. It is the root view contorller of the application's window. It contains the Split View Controller as its only child view controller. Its purpose is to override UITraitCollection and force a custom behavior. */
class TraitOverrideViewController: UIViewController {
  
  /** A threshold above which we want to enforce regular size class, below that compact size class. */
  let CompactSizeClassWidthThreshold: CGFloat = 320.0
  
  // MARK: View Life Cycle
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    
    // If we are large enough, force a regular size class.
    var preferredTrait: UITraitCollection?
    if size.width as CGFloat > CompactSizeClassWidthThreshold {
      preferredTrait = UITraitCollection(horizontalSizeClass: .Regular)
    } else {
      preferredTrait = UITraitCollection(horizontalSizeClass: .Compact)
    }
    
    let childViewController: UIViewController = childViewControllers.first as UIViewController
    setOverrideTraitCollection(preferredTrait, forChildViewController: childViewController)
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
  }
  
}
