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

class SimpleAnimatedTransitioning: NSObject,
UIViewControllerAnimatedTransitioning {
  
  var isPresentation : Bool = false
  
  func transitionDuration(
    transitionContext: UIViewControllerContextTransitioning)
    -> NSTimeInterval {
      return 0.5
  }
  
  func animateTransition(transitionContext:
    UIViewControllerContextTransitioning) {
      
      let fromViewController =
      transitionContext.viewControllerForKey(
        UITransitionContextFromViewControllerKey)
      let fromView = fromViewController!.view
      let toViewController =
      transitionContext.viewControllerForKey(
        UITransitionContextToViewControllerKey)
      let toView = toViewController!.view
      var containerView: UIView =
      transitionContext.containerView()
      if isPresentation {
        containerView.addSubview(toView)
      }
      
      // 1
      var animatingViewController = isPresentation ?
        toViewController : fromViewController
      var animatingView = animatingViewController!.view
      // 2
      var appearedFrame =
      transitionContext.finalFrameForViewController(
        animatingViewController!)
      var dismissedFrame = appearedFrame
      dismissedFrame.origin.y += dismissedFrame.size.height
      // 3
      let initialFrame = isPresentation ? dismissedFrame :
      appearedFrame
      let finalFrame = isPresentation ? appearedFrame : dismissedFrame
      animatingView.frame = initialFrame
      
      UIView.animateWithDuration(
        transitionDuration(transitionContext), delay:0.0,
        usingSpringWithDamping:300.0,
        initialSpringVelocity:5.0,
        options:UIViewAnimationOptions.AllowUserInteraction |
          UIViewAnimationOptions.BeginFromCurrentState, animations:{
            animatingView.frame = finalFrame
        }, completion:{ (value: Bool) in
          if !self.isPresentation {
            fromView.removeFromSuperview()
          }
          transitionContext.completeTransition(true)
      })
  }
  
}

class SimpleTransitioningDelegate: NSObject,
UIViewControllerTransitioningDelegate {
  
  func presentationControllerForPresentedViewController(
    presented: UIViewController!,
    presentingViewController presenting: UIViewController!,
    sourceViewController source: UIViewController!)
    -> UIPresentationController! {
      let presentationController = SimplePresentationController(
        presentedViewController:presented,
        presentingViewController:presenting)
      return presentationController
  }

  func animationControllerForPresentedController(
    presented: UIViewController!,
    presentingController presenting: UIViewController!,
    sourceController source: UIViewController!)
    -> UIViewControllerAnimatedTransitioning! {
      var animationController = SimpleAnimatedTransitioning()
      animationController.isPresentation = true
      return animationController
  }

}


