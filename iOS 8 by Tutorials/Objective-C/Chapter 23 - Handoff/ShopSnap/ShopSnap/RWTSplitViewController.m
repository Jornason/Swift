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

#import "RWTSplitViewController.h"
#import "RWTListViewController.h"
#import "RWTDetailViewController.h"
#import "RWTConstants.h"

@interface RWTSplitViewController () <UISplitViewControllerDelegate>
@end

@implementation RWTSplitViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
  self.delegate = self;
  self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
  [super viewDidLoad];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  // Regular layout: it is a master-detail where master is on the left
  // and detail is on the right.
  if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
    UINavigationController *navController = self.viewControllers.firstObject;
    RWTListViewController *listViewController = navController.viewControllers.firstObject;
    RWTDetailViewController *detailViewController = self.viewControllers.lastObject;
    detailViewController.delegate = (id<RWTDetailViewControllerDelegate>)listViewController;
  }
  [super traitCollectionDidChange:previousTraitCollection];
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
  
  // If the secondary view controller is Detail View Controller...
  if ([secondaryViewController isKindOfClass:[RWTDetailViewController class]]) {
    
    // If Detail View Controller is editing something, default behavior is OK, so return NO.
    RWTDetailViewController *detailViewController = (RWTDetailViewController *)secondaryViewController;
    if (detailViewController.item.length) {
      [detailViewController startEditing];
      return NO;
    }
  }
  
  // Otherwise, pop any view controller in the navigation stack of the primary view controller before collapse.
  if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
    if (primaryViewController.presentedViewController) {
      [(UINavigationController *)primaryViewController popoverPresentationController];
    }
  }
  
  // Return YES because we handled the collapse.
  return YES;
}

#pragma mark - Helper

- (UIViewController *)viewControllerForViewing {
  UINavigationController *navController = self.viewControllers.firstObject;
  RWTListViewController *listViewController = navController.viewControllers.firstObject;
  // If in Compact layout, cancel everything, go to the root of the navigation stack.
  if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
    [navController popToViewController:listViewController animated:YES];
  }
  return listViewController;
}

- (UIViewController *)viewControllerForEditing {
  if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
    
    // If it is the Regular layout, find DetailViewController.
    RWTDetailViewController *detailViewController = self.viewControllers.lastObject;
    return detailViewController;
    
  } else {
    
    UINavigationController *navController = self.viewControllers.firstObject;
    
    // Otherwise, is DetailViewController already active?
    id lastViewController = navController.viewControllers.lastObject;
    if ([lastViewController isKindOfClass:[RWTDetailViewController class]]) {
      
      // Pass it on.
      return lastViewController;
      
    } else {
      
      // Make DetailViewController active via ListViewController.
      RWTListViewController *listViewController = navController.viewControllers.firstObject;
      [listViewController performSegueWithIdentifier:kRWTAddItemSegueIdentifier sender:nil];
      RWTDetailViewController *detailViewController = navController.viewControllers.lastObject;
      return detailViewController;
    }
  }
}

#pragma mark - Handoff

- (void)restoreUserActivityState:(NSUserActivity *)activity {
  
  // What type of activity is it?
  NSString *activityType = activity.activityType;
  
  // This is an activity for ListViewController. Make sure List View is active.
  if ([activityType isEqualToString:kRWTActivityTypeView]) {
    
    UIViewController *controller = [self viewControllerForViewing];
    [controller restoreUserActivityState:activity];
    
  } else if ([activityType isEqualToString:kRWTActivityTypeEdit]) {
    
    // This is an activity for DetailViewController. Make sure Detail View is active.
    UIViewController *controller = [self viewControllerForEditing];
    [controller restoreUserActivityState:activity];
  }
  
  [super restoreUserActivityState:activity];
}

@end
