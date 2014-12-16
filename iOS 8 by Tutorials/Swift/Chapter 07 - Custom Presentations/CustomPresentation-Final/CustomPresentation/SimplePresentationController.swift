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

// 1
class SimplePresentationController: UIPresentationController,
UIAdaptivePresentationControllerDelegate {
  // 2
  var dimmingView: UIView = UIView()
  
  override init(presentedViewController: UIViewController!,
    presentingViewController: UIViewController!) {
      
      super.init(presentedViewController:presentedViewController,
        presentingViewController:presentingViewController)
      // 3
      dimmingView.backgroundColor = UIColor(white:0.0, alpha:0.4)
      dimmingView.alpha = 0.0
  }
  
  override func presentationTransitionWillBegin() {
    // 1
    dimmingView.frame = self.containerView.bounds
    dimmingView.alpha = 0.0
    containerView.insertSubview(dimmingView, atIndex:0)
    // 2
    let coordinator = presentedViewController.transitionCoordinator()
    if (coordinator != nil) {
      // 3
      coordinator!.animateAlongsideTransition({
        (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
        self.dimmingView.alpha = 1.0
        }, completion:nil)
    } else {
      dimmingView.alpha = 1.0
    }
  }
  
  override func dismissalTransitionWillBegin() {
    let coordinator = presentedViewController.transitionCoordinator()
    if (coordinator != nil) {
      coordinator!.animateAlongsideTransition({
        (context:UIViewControllerTransitionCoordinatorContext!) -> Void in
        self.dimmingView.alpha = 0.0
        }, completion:nil)
    } else {
      dimmingView.alpha = 0.0
    }
  }
  
  override func containerViewWillLayoutSubviews() {
    dimmingView.frame = containerView.bounds;
    presentedView().frame = containerView.bounds;
  }
  
  override func shouldPresentInFullscreen() -> Bool {
    return true
  }
  
  func adaptivePresentationStyleForPresentationController(
    controller: UIPresentationController!) -> UIModalPresentationStyle {
      return UIModalPresentationStyle.OverFullScreen
  }
  
  func animationControllerForDismissedController(
    dismissed: UIViewController!)
    -> UIViewControllerAnimatedTransitioning! {
      var animationController = SimpleAnimatedTransitioning()
      animationController.isPresentation = false
      return animationController
  }

}

