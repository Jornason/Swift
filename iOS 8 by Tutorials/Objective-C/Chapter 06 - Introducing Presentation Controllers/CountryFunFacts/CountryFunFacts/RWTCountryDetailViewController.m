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

#import "RWTCountryDetailViewController.h"
#import "RWTCountryPopoverViewController.h"
#import "RWTCountry.h"
#import <QuartzCore/QuartzCore.h>

@interface RWTCountryDetailViewController () <UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation RWTCountryDetailViewController

#pragma mark - Managing the detail item

- (void)setCountry:(RWTCountry *)newCountry {
  if (_country != newCountry) {
    _country = newCountry;
    
    [self configureView];
  }
  
  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }
}

- (void)configureView {
  if (self.country) {
    self.title = self.country.countryName;
    
    self.noSelectionLabel.hidden = YES;
    self.flagImageView.hidden = NO;
    self.flagImageView.image = [UIImage imageNamed:self.country.imageName];
    
    self.quizQuestionLabel.hidden = NO;
    self.answer1Button.hidden = NO;
    self.answer2Button.hidden = NO;
    self.answer3Button.hidden = NO;
    self.answer4Button.hidden = NO;
    
    self.quizQuestionLabel.text = self.country.quizQuestion;
    [self.answer1Button setTitle:self.country.quizAnswers[0] forState:UIControlStateNormal];
    [self.answer2Button setTitle:self.country.quizAnswers[1] forState:UIControlStateNormal];
    [self.answer3Button setTitle:self.country.quizAnswers[2] forState:UIControlStateNormal];
    [self.answer4Button setTitle:self.country.quizAnswers[3] forState:UIControlStateNormal];
    
    [self addCountryDetailButton];
  } else {
    self.noSelectionLabel.hidden = NO;
    self.flagImageView.hidden = YES;
    
    self.quizQuestionLabel.hidden = YES;
    self.answer1Button.hidden = YES;
    self.answer2Button.hidden = YES;
    self.answer3Button.hidden = YES;
    self.answer4Button.hidden = YES;
    
    self.navigationItem.rightBarButtonItem = nil;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (self.splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
    UIBarButtonItem *barButtonItem = [self.splitViewController displayModeButtonItem];
    self.navigationItem.leftBarButtonItem = barButtonItem;
  }
}

- (void)addCountryDetailButton {
  UIBarButtonItem *detailsButton = [[UIBarButtonItem alloc] initWithTitle:@"Facts"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(displayPopover:)];
  
  self.navigationItem.rightBarButtonItem = detailsButton;
}

- (void)updateViewConstraints {
  [super updateViewConstraints];
  
  self.quizQuestionLabel.preferredMaxLayoutWidth = self.view.bounds.size.width - 40;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
  if (displayMode == UISplitViewControllerDisplayModeAllVisible) {
    self.navigationItem.leftBarButtonItem = nil;
  } else {
    UIBarButtonItem *barButtonItem = [svc displayModeButtonItem];
    self.navigationItem.leftBarButtonItem = barButtonItem;
  }
}

// This will colapse the secondary view controller thus displaying the country list when ran on the iPhone.
- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
  return YES;
}


#pragma mark - Alerts and ActionSheets

- (IBAction)quizAnswerButtonPressed:(UIButton *)sender {
  
  // Through the various sections in the chapter I will be describing the old way of showing an alert and actionsheet,
  // then the new way.  Having the code in seperate methods should help with instructing the reader to comment out the
  // previous method call before adding the new one.
  
  // Display AlertView: Previous way
  //[self displayOldAlert];
  
  // Display UIAlertController
  NSString *buttonTitle = sender.titleLabel.text;
  NSString *message = @"";
  if ([buttonTitle isEqualToString:self.country.correctAnswer]) {
    message = @"You answered correctly!";
  } else {
    message = @"That answer is incorrect, please try again.";
  }
  
  UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
  [sheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^void (UIAlertAction *action) {
    NSLog(@"You tapped OK");
  }]];
  
  [self presentViewController:sheet animated:YES completion:nil];
}


#pragma mark - Popovers

- (void)displayPopover:(UIBarButtonItem *)sender {
  if (!self.country) {
    return;
  }
  
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  RWTCountryPopoverViewController *contentViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([RWTCountryPopoverViewController class])];
  contentViewController.country = self.country;
  
  // Display Mode: Change this to display the popover display style.
  contentViewController.modalPresentationStyle = UIModalPresentationPopover;
  
  // Set the popoverPresentationController property of the content view controller
  UIPopoverPresentationController *detailPopover = contentViewController.popoverPresentationController;
  
  
  // Set delegate and add delegate methods to display in fullscreen for iPhone
  detailPopover.delegate = self;
  
  // Button to display popover from
  detailPopover.barButtonItem = sender;
  detailPopover.permittedArrowDirections = UIPopoverArrowDirectionAny;
  [self presentViewController:contentViewController animated:YES completion:nil];
}


#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
  return UIModalPresentationFullScreen;
}

// This will wrap the content view controller in a navigation controller when diplayed in full screen.
- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
  return navController;
}


@end
