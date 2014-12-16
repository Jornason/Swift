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

class AwesomePresentationController: UIPresentationController,
UIViewControllerTransitioningDelegate {
  
  var dimmingView: UIView = UIView()
  var flagImageView: UIImageView = UIImageView(
    frame: CGRect(origin: CGPointZero,
      size: CGSize(width: 160.0, height: 93.0)))
  var selectionObject: SelectionObject?
  var isAnimating = false
  
  override init(presentedViewController: UIViewController!,
    presentingViewController: UIViewController!) {
      super.init(presentedViewController:
        presentedViewController,
        presentingViewController: presentingViewController)
      
      dimmingView.backgroundColor = UIColor.clearColor()
      flagImageView.contentMode =
        UIViewContentMode.ScaleAspectFill
      flagImageView.clipsToBounds = true
      flagImageView.layer.cornerRadius = 4.0
  }
  
  func configureWithSelectionObject(selectionObject:
    SelectionObject) {
      self.selectionObject = selectionObject
      
      var image: UIImage =
      UIImage(named: selectionObject.country.imageName)!
      flagImageView.image = image
      flagImageView.frame = selectionObject.originalCellPosition
  }

  func adaptivePresentationStyleForPresentationController(
    controller: UIPresentationController!) ->
    UIModalPresentationStyle {
      return UIModalPresentationStyle.OverFullScreen
  }
  
  override func frameOfPresentedViewInContainerView() ->
    CGRect {
      return containerView.bounds
  }
  
  override func containerViewWillLayoutSubviews() {
    dimmingView.frame = containerView.bounds
    presentedView().frame = containerView.bounds
  }

  func scaleFlagAndPositionFlag() {
    var flagFrame = flagImageView.frame
    var containerFrame = containerView.frame
    var originYMultiplier: CGFloat = 0.0
    var cellSize = selectionObject!.originalCellPosition.size
    
    if containerFrame.size.width > containerFrame.size.height {
      // Smaller sized flag
      flagFrame.size.width = cellSize.width * 1.5
      flagFrame.size.height = cellSize.height * 1.5
      
      originYMultiplier = 0.25
    } else {
      // Larger sized flag
      flagFrame.size.width = cellSize.width * 1.8
      flagFrame.size.height = cellSize.height * 1.8
      
      originYMultiplier = 0.333
    }
    
    flagFrame.origin.x = (containerFrame.size.width / 2)
      - (flagFrame.size.width / 2)
    flagFrame.origin.y = (containerFrame.size.height *
      originYMultiplier) - (flagFrame.size.height / 2)
    
    flagImageView.frame = flagFrame
  }

  func moveFlagToPresentedPosition(presentedPosition: Bool) {
    let containerFrame = containerView.frame
    
    if presentedPosition {
      // Expand flag and center
      scaleFlagAndPositionFlag()
    } else {
      // Move flag back to original position
      var flagFrame = flagImageView.frame
      flagFrame = selectionObject!.originalCellPosition;
      flagImageView.frame = flagFrame
    }
  }

  func animateFlagToPresentedPosition(presentedPosition: Bool) {
    let coordinator =
    presentedViewController.transitionCoordinator()
    
    coordinator!.animateAlongsideTransition({
      (context: UIViewControllerTransitionCoordinatorContext!)
      -> Void in
      self.moveFlagToPresentedPosition(presentedPosition)
      }, completion: {
        (context: UIViewControllerTransitionCoordinatorContext!)
        -> Void in
        self.isAnimating = false
    })
  }

  override func presentationTransitionWillBegin() {
    super.presentationTransitionWillBegin()
    // 1
    isAnimating = true
    moveFlagToPresentedPosition(false)
    
    // 2
    dimmingView.addSubview(flagImageView)
    containerView.addSubview(dimmingView)
    
    //animateFlagToPresentedPosition(true)
    animateFlagWithBounceToPresentedPosition(true)
  }
  
  // 3
  override func dismissalTransitionWillBegin() {
    super.dismissalTransitionWillBegin()
    
    isAnimating = true
    //animateFlagToPresentedPosition(false)
    animateFlagWithBounceToPresentedPosition(false)
  }
  
  func animateFlagWithBounceToPresentedPosition(
    presentedPosition: Bool) {
      UIView.animateWithDuration(0.7,
        delay: 0.2,
        usingSpringWithDamping: 0.4,
        initialSpringVelocity: 0.0,
        options: UIViewAnimationOptions.CurveEaseOut, {
          self.moveFlagToPresentedPosition(presentedPosition)
        }, completion: { (value: Bool) in
          self.isAnimating = false
      })
  }


}
