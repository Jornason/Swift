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

#import "RWTMasterViewController.h"
#import "RWTColorPaletteProvider.h"
#import "RWTPaletteContainer.h"
#import "UIViewController+Show.h"

#import "RWTDetailViewController.h"

@interface RWTMasterViewController () <RWTPaletteSelectionContainer>
@end

@implementation RWTMasterViewController

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.detailViewController = [[self.splitViewController.viewControllers lastObject] topViewController];

  
  // If we haven't been provided a palette collection, we must be root VC
  if(!self.paletteCollection) {
    self.paletteCollection = [RWTColorPaletteProvider defaultProvider].rootCollection;
    self.title = @"Palettes";
  }
  
  // Subscribe to notifications from the SplitVC that the detail target has changed
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowDetailVCTargetChanged:) name:UIViewControllerShowDetailTargetDidChangeNotification object:nil];
}

- (void)dealloc
{
  // Stop listening to the detail VC target changes
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewControllerShowDetailTargetDidChangeNotification object:nil];
}

- (void)handleShowDetailVCTargetChanged:(id)sender
{
  // Need to make sure that all the visible tableview cells are configured
  //  correctly (i.e. have the correct disclosure indicators)
  for(NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self tableView:self.tableView willDisplayCell:cell
                                 forRowAtIndexPath:indexPath];
  }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.paletteCollection.children.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
  id<RWTPaletteTreeNode> object = self.paletteCollection.children[indexPath.row];
  cell.textLabel.text = [object name];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Update the disclosure indicators as appropriate
  BOOL segueWillPush;
  if([self rowHasChildrenAtIndexPath:indexPath]) {
    segueWillPush = [self rw_showVCWillResultInPushSender:self];
  } else {
    segueWillPush = [self rw_showDetailVCWillResultInPushSender:self];
  }
  
  if (segueWillPush) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if([self rowHasChildrenAtIndexPath:indexPath]) {
    RWTColorPaletteCollection *collection = self.paletteCollection.children[indexPath.row];
    UIStoryboard *storyboard = self.storyboard;
    RWTMasterViewController *newTable = [storyboard instantiateViewControllerWithIdentifier:@"MasterVC"];
    newTable.paletteCollection = collection;
    newTable.title = collection.name;
    [self showViewController:newTable sender:self];
  }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
  if ([self rowHasChildrenAtIndexPath:[self.tableView indexPathForSelectedRow]]) {
    return NO;
  } else {
    return YES;
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    RWTColorPalette *palette = self.paletteCollection.children[indexPath.row];
    [(RWTDetailViewController *)[[segue destinationViewController] topViewController] setColorPalette:palette];
  }
}

#pragma mark - <RWTPaletteSelectionContainer>
- (RWTColorPalette *)rw_currentlySelectedPalette {
  NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
  if (indexPath) {
    if([self rowHasChildrenAtIndexPath:indexPath]) {
      return nil;
    } else {
      return self.paletteCollection.children[indexPath.row];
    }
  }
  return nil;
}

#pragma mark - Utility methods
- (BOOL)rowHasChildrenAtIndexPath:(NSIndexPath *)indexPath {
  id item = self.paletteCollection.children[indexPath.row];
  return ([item isKindOfClass:[RWTColorPaletteCollection class]]);
}

@end
