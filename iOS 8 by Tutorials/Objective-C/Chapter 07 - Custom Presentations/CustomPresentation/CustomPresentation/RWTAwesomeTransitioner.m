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

#import "RWTAwesomeTransitioner.h"
#import "RWTAwesomePresentationController.h"
#import "RWTCountriesViewController.h"

@implementation RWTAwesomeTransitioningDelegate

- (instancetype)initWithSelectedObject:(RWTSelectionObject *)selectedObject {
  self = [super init];
  if (self) {
    _selectedObject = selectedObject;
  }
  return self;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
  RWTAwesomePresentationController *presentationController = [[RWTAwesomePresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
  [presentationController configureWithSelectionObject:self.selectedObject];
  
  return presentationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
  
  RWTAwesomeAnimatedTransitioning *animationController = [[RWTAwesomeAnimatedTransitioning alloc] initWithSelectedObject:self.selectedObject isPresentation:YES];
  return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
  
  RWTAwesomeAnimatedTransitioning *animationController = [[RWTAwesomeAnimatedTransitioning alloc] initWithSelectedObject:self.selectedObject isPresentation:NO];
  return animationController;
}

@end


@implementation RWTAwesomeAnimatedTransitioning

- (instancetype)initWithSelectedObject:(RWTSelectionObject *)selectedObject isPresentation:(BOOL)isPresentation {
  self = [super init];
  if (self) {
    _selectedObject = selectedObject;
    _isPresentation = isPresentation;
  }
  return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
  return 0.7;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIView *fromView = [fromViewController view];
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView *toView = [toViewController view];
  
  UIView *containerView = [transitionContext containerView];
  
  BOOL isPresentation = self.isPresentation;
  
  if (isPresentation) {
    [containerView addSubview:toView];
  }
  
  UIViewController *animatingViewController = isPresentation? toViewController : fromViewController;
  UIView *animatingView = [animatingViewController view];
  
  RWTCountriesViewController *countriesViewController = (RWTCountriesViewController *)(isPresentation? fromViewController : toViewController);
  
  animatingView.frame = [transitionContext finalFrameForViewController:animatingViewController];
  
  CGRect appearedFrame = [transitionContext finalFrameForViewController:animatingViewController];
  CGRect dismissedFrame = appearedFrame;
  dismissedFrame.origin.y += dismissedFrame.size.height;
  
  CGRect initialFrame = isPresentation ? dismissedFrame : appearedFrame;
  CGRect finalFrame = isPresentation ? appearedFrame : dismissedFrame;
  
  [animatingView setFrame:initialFrame];
  
  if (![self isPresentation]) {
    // The cell is off the screen and we want to hide it before it appears on screen,
    // so the flage appears to move back in place.
    [countriesViewController hideImage:YES atIndexPath:self.selectedObject.selectedCellIndexPath];
  }
  
  [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0
                      options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                   animations:^{
                     
                     [animatingView setFrame:finalFrame];
                     [countriesViewController changeCellSpacingForPresentation:isPresentation ? YES : NO];
                     
                   } completion:^(BOOL finished) {
                     
                     if (![self isPresentation]) {
                       
                       // Show the image after the animation is complete.
                       [countriesViewController hideImage:NO atIndexPath:self.selectedObject.selectedCellIndexPath];
                       
                       // Fade view out so there is no flicker on the flag before removing the view.
                       [UIView animateWithDuration:0.3 animations:^{
                         fromView.alpha = 0.0;
                       } completion:^(BOOL finished) {
                         [fromView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                       }];
                       
                     } else {
                       [transitionContext completeTransition:YES];
                     }
                     
                   }];
}

@end
