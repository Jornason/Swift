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

#import "RWTDetailViewController.h"
#import "RWTConstants.h"

@interface RWTDetailViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation RWTDetailViewController

#pragma mark - Custom Accessors

- (void)setItem:(NSString *)item {
  _item = [item copy];
  self.textField.text = _item;
  [self.userActivity setNeedsSave:YES];
}

#pragma mark - View Life Cycle

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad { 
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
  self.textField.text = self.item;
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
  if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
    [self startEditing];
  }
  [super viewDidAppear:animated];
}

#pragma mark - Public

- (void)startEditing {
  [self.textField becomeFirstResponder];
}

- (void)stopEditing {
  [self.textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:kRWTActivityTypeEdit];
  userActivity.title = @"Editing Shopping List Item";
  NSString *activityItem = (textField.text.length) ? textField.text : @"";
  userActivity.userInfo = @{ kRWTActivityItemKey : activityItem };
  self.userActivity = userActivity;
  [self.userActivity  becomeCurrent];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.userActivity invalidate];
  [textField resignFirstResponder];
  [self.delegate detailViewController:self didFinishWithUpdatedItem:textField.text];
  return YES;
}

#pragma mark - NSNotification

- (void)textFieldTextDidChange:(NSNotification *)notification {
  self.item = self.textField.text;
  [self.userActivity setNeedsSave:YES];
}

#pragma mark - Handoff

- (void)updateUserActivityState:(NSUserActivity *)activity {
  NSString *activityItem = (self.textField.text.length) ? self.textField.text : @"";
  [activity addUserInfoEntriesFromDictionary:@{ kRWTActivityItemKey : activityItem }];
  [super updateUserActivityState:activity];
}

- (void)restoreUserActivityState:(NSUserActivity *)activity {
  NSString *item = activity.userInfo[kRWTActivityItemKey];
  self.textField.text = item;
  [super restoreUserActivityState:activity];
}


@end
