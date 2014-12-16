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

#import "RWTViewController.h"
#import "RWTColorSwatchSelectionDelegate.h"
#import "RWTColorSwatchCollectionViewController.h"

@interface RWTViewController () <RWTColorSwatchSelectionDelegate>

@property (weak, nonatomic) IBOutlet UIView *swatchSelectorView;
@property (weak, nonatomic) IBOutlet UIView *swatchDetailView;


@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *layoutConstraintsForTall;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *layoutConstraintsForWide;

@end


@implementation RWTViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  // Set up swatch selection delegate on child view controllers
  [self.childViewControllers enumerateObjectsUsingBlock:^(id vc, NSUInteger idx, BOOL *stop) {
    if([vc respondsToSelector:@selector(setSwatchSelectionDelegate:)]) {
      [vc setSwatchSelectionDelegate:self];
    }
  }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  // Pass on to child view controllers
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  
  // Update the auto-layout based on the orientation of this VC
  BOOL transitioningToWide = size.width > size.height;
  NSArray *constraintsToUninstall = transitioningToWide ? self.layoutConstraintsForTall : self.layoutConstraintsForWide;
  NSArray *constraintsToInstall = transitioningToWide ? self.layoutConstraintsForWide : self.layoutConstraintsForTall;
  
  // Purge any things required
  [self.view layoutIfNeeded];
  
  [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    // Uninstall the old restraints
    [NSLayoutConstraint deactivateConstraints:constraintsToUninstall];
    // Animate to the new constraints
    [NSLayoutConstraint activateConstraints:constraintsToInstall];
    [self.view layoutIfNeeded];
  }
     completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
       
     }];
  
}

#pragma mark - <RWColorSwatchSelectionDelegate>
- (void)didSelectColorSwatch:(RWTColorSwatch *)swatch sender:(id)sender {
  // Send the swatch to all the VCs which adopt the swatch selection delegate protocol
  [self.childViewControllers enumerateObjectsUsingBlock:^(id vc, NSUInteger idx, BOOL *stop) {
    // Don't send back to sender
    if([vc conformsToProtocol:@protocol(RWTColorSwatchSelectionDelegate)] && vc != sender) {
      [vc didSelectColorSwatch:swatch sender:sender];
    }
  }];
}

@end
