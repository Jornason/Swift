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
 *  RWTMasterViewController.m
 *  Places
 *
 *  Created by Soheil Azarpour on 6/24/14.
 *  Copyright (c) 2014 Razeware LLC. All rights reserved.
 */

#import "RWTMasterViewController.h"
#import "RWTMapViewController.h"
#import "RWTPlaceManager.h"
#import "RWTTableViewCell.h"

static NSString * const kRWTShowDetailSegueIdentifier = @"RWTShowDetailSegueIdentifier";
static NSString * const kRWTMasterTableViewCellIdentifier = @"RWTMasterTableViewCellIdentifier";

@interface RWTMasterViewController ()
@property (copy, nonatomic) NSArray *places;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation RWTMasterViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
  self.title = @"Places";
  
  __weak RWTMasterViewController *weakSelf = self;
  [[RWTPlaceManager sharedManager] fetchPlacesWithCompletion:^(NSArray *places) {
    weakSelf.places = places;
    [weakSelf.tableView reloadData];
    [weakSelf autoSelectFirstPlace];
    [weakSelf autoDisplaySelectedPlaceIfApplicable];
  }];
  
  [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  id viewController = segue.destinationViewController;
  if ([viewController isKindOfClass:[RWTMapViewController class]]) {
    RWTPlace *place = [self selectedPlace];
    [(RWTMapViewController *)viewController displayPlace:place];
  }
}

#pragma mark - Public

- (RWTPlace *)selectedPlace {
  return self.places[self.selectedIndexPath.row];
}

#pragma mark - Helper

/** @brief Auto select the 1st place in array of places, if none is selected. */
- (void)autoSelectFirstPlace {
  if (!self.selectedIndexPath) {
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  }
}

/** @brief Auto dispaly the selected Place if split view controller is expanded. */
- (void)autoDisplaySelectedPlaceIfApplicable {
  // If split view controller is expanded, displayed the selected item in Map View.
  if (!self.splitViewController.isCollapsed) {
    [self performSegueWithIdentifier:kRWTShowDetailSegueIdentifier sender:self.selectedPlace];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RWTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRWTMasterTableViewCellIdentifier];
  RWTPlace *place = self.places[indexPath.row];
  cell.imageTileLabel.text = place.title;
  cell.imageDateLabel.text = place.subtitle;
  cell.backgroundImageView.image = place.image;
  return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // This delegate method is called before the cell is selected and its associated segue is invoked. Keep a reference to this index path and update the destination view controller (Map View Controller) appropriately.
  self.selectedIndexPath = indexPath;
  return indexPath;
}

@end
