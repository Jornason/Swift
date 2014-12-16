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
 *  RWTTraitOverrideViewController.m
 *  Places
 *
 *  Created by Soheil Azarpour on 6/24/14.
 *  Copyright (c) 2014 Razeware LLC. All rights reserved.
 */

#import "RWTTraitOverrideViewController.h"

/** @brief A threshold above which we want to enforce regular size class, below that compact size class. */
static CGFloat const kRWTCompactSizeClassWidthThreshold = 320.0;

@implementation RWTTraitOverrideViewController

#pragma mark - View Life Cycle

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  // If we are large enough, force a regular size class.
  UITraitCollection *preferredTrait;
  if (size.width > kRWTCompactSizeClassWidthThreshold) {
    preferredTrait = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular];
  } else {
    preferredTrait = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact];
  }
  
  // We know for sure there is only 1 child view controller.
  UIViewController *childViewController = self.childViewControllers.firstObject;
  [self setOverrideTraitCollection:preferredTrait forChildViewController:childViewController];
  
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

@end
