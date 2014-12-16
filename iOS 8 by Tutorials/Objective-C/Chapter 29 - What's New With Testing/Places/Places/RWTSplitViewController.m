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
 *
 *  RWTSplitViewController.m
 *  Places
 *
 *  Created by Soheil Azarpour on 6/24/14.
 *  Copyright (c) 2014 Razeware LLC. All rights reserved.
 */

#import "RWTSplitViewController.h"
#import "RWTMasterViewController.h"
#import "RWTMapViewController.h"

@interface RWTSplitViewController () <UISplitViewControllerDelegate>
@end

@implementation RWTSplitViewController

#pragma mark - View Life Cycle

- (void)awakeFromNib {
  self.delegate = self;
  self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
  [super awakeFromNib];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  if ([self.viewControllers.lastObject isKindOfClass:[RWTMapViewController class]]) {
    RWTMapViewController *mapViewController = self.viewControllers.lastObject;
    if ([self.viewControllers.firstObject isKindOfClass:[UINavigationController class]]) {
      UINavigationController *navController = self.viewControllers.firstObject;
      RWTMasterViewController *masterViewController = navController.viewControllers.firstObject;
      RWTPlace *selectedPlace = [masterViewController selectedPlace];
      [mapViewController displayPlace:selectedPlace];
    }
  }
  [super traitCollectionDidChange:previousTraitCollection];
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
  // If the secondary view controller is Map View Controller and it is displaying a place, return NO for default behavior.
  if ([secondaryViewController isKindOfClass:[RWTMapViewController class]]) {
    if ([(RWTMapViewController *)secondaryViewController isDisplayingPlace]) {
      return NO;
    }
  }
  // Otherwise, pop any view controller in the navigation stack of the primary view controller before collapse.
  if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
    [(UINavigationController *)primaryViewController popToRootViewControllerAnimated:YES];
  }
  // Return YES because we handled the collapse.
  return YES;
}

@end
