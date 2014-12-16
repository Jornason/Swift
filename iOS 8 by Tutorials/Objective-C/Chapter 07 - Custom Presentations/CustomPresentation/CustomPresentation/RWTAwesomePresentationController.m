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

#import "RWTAwesomePresentationController.h"
#import "RWTSelectionObject.h"
#import "RWTCountry.h"

@interface RWTAwesomePresentationController ()

@property (strong, nonatomic) UIImageView *flagImageView;
@property (strong, nonatomic) UIView *dimmingView;
@property (strong, nonatomic) UIView *backgroundColorView;
@property (strong, nonatomic) RWTSelectionObject *selectionObject;
@property (assign, nonatomic) BOOL isAnimating;

@end

@implementation RWTAwesomePresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
  self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
  if (self) {
    _dimmingView = [[UIView alloc] init];
    _dimmingView.backgroundColor = [UIColor clearColor];
    
    _flagImageView = [[UIImageView alloc] init];
    _flagImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _isAnimating = NO;
  }
  return self;
}

- (void)configureWithSelectionObject:(RWTSelectionObject *)selectionObject {
  self.selectionObject = selectionObject;
  
  self.flagImageView.image = [UIImage imageNamed:self.selectionObject.country.imageName];
  self.flagImageView.frame = self.selectionObject.originalCellPosition;
}

- (CGRect)frameOfPresentedViewInContainerView {
  CGRect containerBounds = self.containerView.bounds;
  return containerBounds;
}

- (void)addViewsToDimmingView {
  [self.dimmingView addSubview:self.backgroundColorView];
  [self.dimmingView addSubview:self.flagImageView];
  
  [self.containerView addSubview:self.dimmingView];
}
- (void)containerViewWillLayoutSubviews {
  self.dimmingView.frame = self.containerView.bounds;
  self.backgroundColorView.frame = self.containerView.bounds;
}

- (void)containerViewDidLayoutSubviews {
  
  if (self.isAnimating) {
    return;
  }
  
  [self scaleFlagAndPositionFlag];
}

- (void)presentationTransitionWillBegin {
  [super presentationTransitionWillBegin];
  
  self.isAnimating = YES;
  
  [self moveFlagToPresentedPosition:NO];
  
  [self addViewsToDimmingView];
  
  // animateFlagToPresentedPosition: will animate the flag alongside
  // of the transition coordinator's animation
  //[self animateFlagToPresentedPosition:YES];
  
  // animateFlagWithBounceToPresentedPosition: will animate the flag
  // seperately of the transition coordinator's animation
  [self animateFlagWithBounceToPresentedPosition:YES];
}

- (void)dismissalTransitionWillBegin {
  [super dismissalTransitionWillBegin];
  
  self.isAnimating = YES;
  
  // animateFlagToPresentedPosition: will animate the flag alongside
  // of the transition coordinator's animation
  //[self animateFlagToPresentedPosition:NO];
  
  // animateFlagWithBounceToPresentedPosition: will animate the flag
  // seperately of the transition coordinator's animation
  [self animateFlagWithBounceToPresentedPosition:NO];
}


#pragma mark - Custom Animation

- (void)scaleFlagAndPositionFlag {
  // This method is used to initially scale the flag and
  // when the device changes view sizes for orientation changes
  
  CGRect flagFrame = self.flagImageView.frame;
  CGRect containerFrame = self.containerView.frame;
  
  CGFloat originYMultiplier = 0.0;
  
  if (containerFrame.size.width > containerFrame.size.height) {
    // Smaller sized flag
    flagFrame.size.width = self.selectionObject.originalCellPosition.size.width * 1.5;
    flagFrame.size.height = self.selectionObject.originalCellPosition.size.height * 1.5;
    
    originYMultiplier = 0.25;
  } else {
    // Larger sized flag
    flagFrame.size.width = self.selectionObject.originalCellPosition.size.width * 1.8;
    flagFrame.size.height = self.selectionObject.originalCellPosition.size.height * 1.8;
    
    originYMultiplier = 0.333;
  }
  
  flagFrame.origin.x = (containerFrame.size.width / 2) - (flagFrame.size.width / 2);
  flagFrame.origin.y = (containerFrame.size.height * originYMultiplier) - (flagFrame.size.height / 2);
  
  self.flagImageView.frame = flagFrame;
}

- (void)moveFlagToPresentedPosition:(BOOL)presentedPosition {
  
  if (presentedPosition) {
    // Expand flag and center
    [self scaleFlagAndPositionFlag];
    
  } else {
    // Move flag back to original position
    CGRect flagFrame = self.flagImageView.frame;
    flagFrame = self.selectionObject.originalCellPosition;
    
    [self.flagImageView setFrame:flagFrame];
  }
}

- (void)animateFlagToPresentedPosition:(BOOL)presentedPosition {
  
  [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    
    [self moveFlagToPresentedPosition:NO];
    
  } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    
    self.isAnimating = NO;
    
  }];
}

- (void)animateFlagWithBounceToPresentedPosition:(BOOL)presentedPosition {
  
  [UIView animateWithDuration:0.7 delay:0.2 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    
    [self moveFlagToPresentedPosition:presentedPosition];
    
  } completion:^(BOOL finished) {
    
    self.isAnimating = NO;
    
  }];
}

@end
