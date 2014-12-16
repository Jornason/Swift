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

#import "RWTSimpleTransitioner.h"
#import "RWTSimplePresentationController.h"

@implementation RWTSimpleTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
  
  return [[RWTSimplePresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
  RWTSimpleAnimatedTransitioning *animationController = [[RWTSimpleAnimatedTransitioning alloc] init];
  [animationController setIsPresentation:YES];
  
  return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
  RWTSimpleAnimatedTransitioning *animationController = [[RWTSimpleAnimatedTransitioning alloc] init];
  [animationController setIsPresentation:NO];
  
  return animationController;
}

@end


@implementation RWTSimpleAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
  return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIView *fromView = fromViewController.view;
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView *toView = toViewController.view;
  
  UIView *containerView = transitionContext.containerView;
  
  BOOL isPresentation = self.isPresentation;
  
  if (isPresentation) {
    [containerView addSubview:toView];
  }
  
  UIViewController *animatingViewController = isPresentation ? toViewController : fromViewController;
  UIView *animatingView = animatingViewController.view;
  
  
  
  CGRect appearedFrame = [transitionContext finalFrameForViewController:animatingViewController];
  CGRect dismissedFrame = appearedFrame;
  dismissedFrame.origin.y += dismissedFrame.size.height;
  
  
  
  
  CGRect initialFrame = isPresentation ? dismissedFrame : appearedFrame;
  CGRect finalFrame = isPresentation ? appearedFrame : dismissedFrame;
  
  [animatingView setFrame:initialFrame];
  
  [UIView animateWithDuration:[self transitionDuration:transitionContext]
                        delay:0
       usingSpringWithDamping:300.0
        initialSpringVelocity:5.0
                      options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                   animations:^{
                     [animatingView setFrame:finalFrame];
                   }
                   completion:^(BOOL finished){
                     if (![self isPresentation]) {
                       [fromView removeFromSuperview];
                     }
                     [transitionContext completeTransition:YES];
                   }];
}

@end

