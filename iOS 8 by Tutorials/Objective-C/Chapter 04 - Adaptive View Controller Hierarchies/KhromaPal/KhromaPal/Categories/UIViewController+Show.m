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

@import UIKit;
#import "UIViewController+Show.h"

@implementation UIViewController (ShowMethods)

- (BOOL)rw_showVCWillResultInPushSender:(id)sender
{
  // Interrogate the VC hierarchy to find a VC that implements the method
  UIViewController *target = [self targetViewControllerForAction:@selector(rw_showVCWillResultInPushSender:) sender:sender];
  if(target) {
    return [target rw_showVCWillResultInPushSender:sender];
  } else {
    // A vanilla VC doesn't push a 'show' action
    return NO;
  }
}

- (BOOL)rw_showDetailVCWillResultInPushSender:(id)sender
{
  // Interrogate the VC hierarchy
  UIViewController *target = [self targetViewControllerForAction:@selector(rw_showDetailVCWillResultInPushSender:) sender:sender];
  if(target) {
    return [target rw_showDetailVCWillResultInPushSender:sender];
  } else {
    // Standard VC won't push a detail action
    return NO;
  }
}

@end


@implementation UINavigationController (ShowMethods)

- (BOOL)rw_showVCWillResultInPushSender:(id)sender
{
  // A nav controller implements this and always pushes
  return YES;
}

@end


@implementation UISplitViewController (ShowMethods)

- (BOOL)rw_showVCWillResultInPushSender:(id)sender
{
  // Split VC does nothing with a show message - so it's not a push but a
  // modal. Ususally the show messages are caught by a nav ctrler
  return NO;
}

- (BOOL)rw_showDetailVCWillResultInPushSender:(id)sender
{
  if(self.collapsed) {
    // If collapsed then message gets converted to showVC and sent to
    // the primary VC
    UIViewController *primaryVC = self.viewControllers.lastObject;
    return [primaryVC rw_showVCWillResultInPushSender:sender];
  } else {
    // When we're not collapsed then don't push
    return NO;
  }
}

@end
