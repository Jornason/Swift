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

#import "RWTSimplePresentationController.h"

@interface RWTSimplePresentationController ()

@property (strong, nonatomic) UIView *dimmingView;

@end

@implementation RWTSimplePresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
  self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
  if (self) {
    _dimmingView = [[UIView alloc] init];
    _dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    _dimmingView.alpha = 0.0;
  }
  
  return self;
}


#pragma mark - Overridden Methods

- (void)presentationTransitionWillBegin {
  UIViewController *presentedViewController = self.presentedViewController;
  self.dimmingView.frame = self.containerView.bounds;
  self.dimmingView.alpha = 0.0;
  
  [self.containerView insertSubview:self.dimmingView atIndex:0];
  
  if ([presentedViewController transitionCoordinator]) {
    [[presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
      self.dimmingView.alpha = 1.0;
    } completion:nil];
  } else {
    self.dimmingView.alpha = 1.0;
  }
}

- (void)dismissalTransitionWillBegin {
  if (self.presentedViewController.transitionCoordinator) {
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
      self.dimmingView.alpha = 0.0;
    } completion:nil];
    
  } else {
    self.dimmingView.alpha = 0.0;
  }
}

- (void)containerViewWillLayoutSubviews {
  self.dimmingView.frame = self.containerView.bounds;
  self.presentedView.frame = self.containerView.bounds;
}

- (BOOL)shouldPresentInFullscreen {
  return YES;
}


#pragma mark - UIAdaptivePresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyle {
  return UIModalPresentationOverFullScreen;
}

@end
