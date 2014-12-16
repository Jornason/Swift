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
  
  // MARK: View Life Cycle
  
  override func viewDidLoad()  {
    delegate = self
    preferredDisplayMode = .AllVisible
    super.viewDidLoad()
  }
  
  override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
    
    // Regular layout: it is a master-detail where master is on the left
    // and detail is on the right.
    if traitCollection.horizontalSizeClass == .Regular {
      
      let navController = viewControllers.first as UINavigationController
      let listViewController = navController.viewControllers?.first as ListViewController
      
      let detailViewController = viewControllers.last as DetailViewController
      detailViewController.delegate = listViewController
    }
    
    super.traitCollectionDidChange(previousTraitCollection)
  }
  
  // MARK: UISplitViewControllerDelegate
  
  func splitViewController(splitViewController: UISplitViewController!, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
    
    // If the secondary view controller is Detail View Controller...
    if secondaryViewController.isKindOfClass(DetailViewController.self) {
      
      // If Detail View Controller is editing something, default behavior is OK, so return NO.
      let detailViewController = secondaryViewController as DetailViewController
      if detailViewController.item?.isEmpty == false {
        detailViewController.startEditing()
        return false
      }
    }
    
    // Otherwise we handle the collapse.
    if primaryViewController.isKindOfClass(UINavigationController.self) {
      
      // If there is modally presented view controller, pop.
      if primaryViewController.presentedViewController != nil {
        (primaryViewController as UINavigationController).popToRootViewControllerAnimated(true)
      }
    }
    
    // Return YES because we handled the collapse.
    return true;
  }
  
  // MARK: Helper
  
  func viewControllerForViewing () -> UIViewController {
    let navController = viewControllers.first as UINavigationController
    let listViewController = navController.viewControllers?.first as ListViewController
    
    // If in Compact layout, cancel everything, go to the root of the navigation stack.
    if traitCollection.horizontalSizeClass == .Compact {
      navController.popToViewController(listViewController, animated: true)
    }
    return listViewController
  }
  
  func viewControllerForEditing () -> UIViewController {
    if traitCollection.horizontalSizeClass == .Regular {
      
      // If it is the Regular layout, find DetailViewController.
      let detailViewController = viewControllers.last as DetailViewController
      return detailViewController
      
    } else {
      
      let navController = viewControllers.first as UINavigationController
      
      // Otherwise, is DetailViewController already active?
      var lastViewController: AnyObject? = navController.viewControllers.last
      if lastViewController is DetailViewController {
        
        // Pass it on.
        let detailViewController = lastViewController as DetailViewController
        return detailViewController
        
      } else {
        
        // Make DetailViewController active via ListViewController.
        let listViewController = navController.viewControllers?.first as ListViewController
        listViewController.performSegueWithIdentifier(AddItemSegueIdentifier, sender: nil)
        let detailViewController = navController.viewControllers.last as DetailViewController
        return detailViewController
      }
    }
  }
  
}