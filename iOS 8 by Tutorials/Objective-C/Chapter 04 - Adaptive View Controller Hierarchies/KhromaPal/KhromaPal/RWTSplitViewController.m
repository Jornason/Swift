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
#import "RWTNavigationController.h"

@implementation RWTSplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    
    // Prepare the nav bar item
    if([self.viewControllers.lastObject isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navCltr = (UINavigationController *)self.viewControllers.lastObject;
        // Want to show the displayModeButtonItem
        navCltr.topViewController.navigationItem.leftBarButtonItem = self.displayModeButtonItem;
    }

}

#pragma mark - Utility methods
- (UIViewController *)noPaletteSelectedVC
{
    UIStoryboard *storyboard = self.storyboard;
    if(storyboard) {
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NoPaletteSelectedVC"];
        return[[RWTNavigationController alloc] initWithRootViewController:vc];
    }
    return nil;
}

#pragma mark - <UISplitViewControllerDelegate>

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    // Is the primary view controller currently displaying a palette?
    if ([primaryViewController conformsToProtocol:@protocol(RWTPaletteDisplayContainer)]) {
        id<RWTPaletteDisplayContainer> paletteDisplayContainer = (id<RWTPaletteDisplayContainer>)primaryViewController;
        if([paletteDisplayContainer rw_currentlyDisplayedPalette]) {
            // We're happy with the default behaviour (to pop it off the nav stack)
            return nil;
        }
    }
    
    // It must be a level of table view controller. Send back an "unselected" VC
    return [self noPaletteSelectedVC];
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    // If we are currently displayed the palette which matches the selected
    // row in the primary table view, then push that on to the stack. Otherwise
    // default behaviour
    if([primaryViewController conformsToProtocol:@protocol(RWTPaletteSelectionContainer)] &&
       [secondaryViewController conformsToProtocol:@protocol(RWTPaletteDisplayContainer)]) {
        id<RWTPaletteSelectionContainer> paletteSelectionContainer = (id<RWTPaletteSelectionContainer>)primaryViewController;
        id<RWTPaletteDisplayContainer> paletteDisplayContainer = (id<RWTPaletteDisplayContainer>)secondaryViewController;
        
        RWTColorPalette *selected = [paletteSelectionContainer rw_currentlySelectedPalette];
        RWTColorPalette *displayed = [paletteDisplayContainer rw_currentlyDisplayedPalette];
        if(selected && selected == displayed) {
            // We're happy with the default behaviour to pop it off
            return NO;
        }
    }
    // We don't want anything to happen - say we've dealt with it
    return YES;
}

@end
