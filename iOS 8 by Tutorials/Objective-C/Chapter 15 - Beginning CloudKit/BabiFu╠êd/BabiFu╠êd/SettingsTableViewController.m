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


#import "SettingsTableViewController.h"
#import "Model.h"


@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

#pragma mark - Table view data source

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Settings";
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateLogin];
}

- (void) updateLogin {
  NSIndexPath* ip = [NSIndexPath indexPathForRow:0 inSection:0];
  UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:ip];
  
  [[Model model].user loggedInToICloud:^(CKAccountStatus accountStatus, NSError *error) {
    NSString* text = @"Unknown Status";
    if (accountStatus == CKAccountStatusNoAccount) {
      text = @"Not logged in to iCloud";
    } else if (accountStatus == CKAccountStatusAvailable) {
      [[Model model].user userInfo:^(CKDiscoveredUserInfo *userInfo, NSError *error) {
        if (userInfo) {
          dispatch_async(dispatch_get_main_queue(), ^{
            cell.textLabel.text = [NSString stringWithFormat:@"Logged in as %@ %@", userInfo.firstName, userInfo.lastName];
          });
        }
      }];
      text = @"Logged in";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      cell.textLabel.text = text;
      self.discoverabilitySwitch.enabled = accountStatus == CKAccountStatusAvailable;
      [self.tableView reloadData];
    });
  }];
}

- (IBAction)setDiscoverable:(id)sender {
  [[Model model].user loggedInToICloud:^(CKAccountStatus accountStatus, NSError *error) {
    if (accountStatus == CKAccountStatusAvailable) {
      [[Model model].user requestDiscoverabilityPermission:^(BOOL discoverable) {
        dispatch_async(dispatch_get_main_queue(), ^{
          self.discoverabilitySwitch.on = discoverable;
        });
      }];
    }
  }];
}

- (IBAction)discoverContacts:(id)sender {
  [[Model model].user findContacts:^(NSArray *userInfos, NSError *error) {
    if (!error) {
      [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Found %lu contacts", (unsigned long)userInfos.count] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
  }];
}

@end
