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

#import "RWTListViewController.h"
#import "RWTDetailViewController.h"
#import "RWTPersistentStore.h"
#import "RWTConstants.h"

static NSString * const kRWTTableViewCellIdentifier = @"RWTTableViewCellIdentifier";
static NSString * const kRWTEditItemSegueIdentifier = @"RWTEditItemSegueIdentifier";

@interface RWTListViewController () <RWTDetailViewControllerDelegate>
/** @brief A mutable array of shopping list items. */
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic, readwrite) NSIndexPath *selectedItemIndexPath;
@end

@implementation RWTListViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
  self.title = @"Shopping List";
  
  // Restore items from previous session.
  __weak typeof(self) weakSelf = self;
  [[RWTPersistentStore defaultStore] fetchItems:^(NSArray *items) {
    weakSelf.items = items.mutableCopy;
    [weakSelf.tableView reloadData];
    if (items.count) {
      [weakSelf startUserActivity];
    }
  }];
  
  [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSString *identifier = segue.identifier;
  RWTDetailViewController *controller = segue.destinationViewController;
  controller.delegate = self;
  
  if ([identifier isEqualToString:kRWTEditItemSegueIdentifier]) {
    controller.item = [self selectedItem];
  }
  else if ([identifier isEqualToString:kRWTAddItemSegueIdentifier]) {
    if (self.selectedItemIndexPath) {
      [self.tableView deselectRowAtIndexPath:self.selectedItemIndexPath animated:YES];
    }
    self.selectedItemIndexPath = nil;
  }
  [self stopUserActivity];
}

#pragma mark - Public

- (NSString *)selectedItem {
  if (self.selectedItemIndexPath) {
    return self.items[self.selectedItemIndexPath.row];
  }
  return @"";
}

#pragma mark - Helper

/** @brief A helper method to add a new item to items array, if the new item doesn't already exist. */
- (void)addItemToItemsIfUnique:(NSString *)item {
  if (item.length && ![self.items containsObject:item]) {
    [self.items addObject:item];
  }
}

/** @brief If in a compact size class, e.g. iPhone once Detail View Controller calls back on its delegate, all we have to do is pop Detail View Controller from navigation stack. But for a regualr size class, e.g. iPad, popToViewController is a noop but we still have to clear previous edit. Since we make similar calls from muliple places in the code, this helper method refactors those calls. */
- (void)endEditingInDetailViewController:(RWTDetailViewController *)controller {
  [self.navigationController popToViewController:self animated:YES];
  controller.item = nil;
  [controller stopEditing];
}

#pragma mark - IBActions

- (IBAction)unwindDetailViewController:(UIStoryboardSegue *)unwindSegue {
  [self endEditingInDetailViewController:unwindSegue.sourceViewController];
  if (self.selectedItemIndexPath) {
    [self.tableView deselectRowAtIndexPath:self.selectedItemIndexPath animated:YES];
  }
  self.selectedItemIndexPath = nil;
  [self stopUserActivity];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRWTTableViewCellIdentifier];
  cell.textLabel.text = self.items[indexPath.row];
  return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // We are going to display detail for an item. So ListViewController is not going to be active anymore. Stop broadcasting.
  [self.userActivity invalidate];
  self.selectedItemIndexPath = indexPath;
  return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // Update data source and UI.
  NSString *itemToRemove = self.items[indexPath.row];
  [self.items removeObject:itemToRemove];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
  
  // Update persistent store.
  [[RWTPersistentStore defaultStore] updateStoreWithItems:self.items];
  
  // If this was the selected index path, we need to do more clean up.
  if ([indexPath isEqual:self.selectedItemIndexPath]) {
    self.selectedItemIndexPath = nil;
    [self.splitViewController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      if ([obj isKindOfClass:[RWTDetailViewController class]]) {
        [self endEditingInDetailViewController:obj];
        *stop = YES;
      }
    }];
  }
  
  if (self.items.count) {
    [self.userActivity setNeedsSave:YES];
  }
  else {
    [self stopUserActivity];
  }
}

#pragma mark - RWTDetailViewControllerDelegate

- (void)detailViewController:(RWTDetailViewController *)controller didFinishWithUpdatedItem:(NSString *)item {
  // Did user edit an item, or added a new item?
  if (self.selectedItemIndexPath) {
    
    // If item is empty string, treat it as deletion of the item.
    if (!item.length) {
      [self.items removeObjectAtIndex:self.selectedItemIndexPath.row];
    } else {
      [self.items replaceObjectAtIndex:self.selectedItemIndexPath.row withObject:item];
    }
    
  } else {
    // This is a new item. Add it to the list.
    [self addItemToItemsIfUnique:item];
  }
  
  self.selectedItemIndexPath = nil;
  [self.tableView reloadData];
  [self endEditingInDetailViewController:controller];
  
  [[RWTPersistentStore defaultStore] updateStoreWithItems:self.items];
  [[RWTPersistentStore defaultStore] commit];
  
  if (self.items.count) {
    [self startUserActivity];
  }
}

#pragma mark - Handoff

- (void)startUserActivity {
  NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:kRWTActivityTypeView];
  activity.title = @"Viewing Shopping List";
  activity.userInfo = @{kRWTActivityItemsKey: self.items};
  self.userActivity = activity;
  [self.userActivity becomeCurrent];
}

- (void)updateUserActivityState:(NSUserActivity *)activity {
  [activity addUserInfoEntriesFromDictionary:@{kRWTActivityItemsKey: self.items}];
  [super updateUserActivityState:activity];
}

- (void)stopUserActivity {
  [self.userActivity invalidate];
}

- (void)restoreUserActivityState:(NSUserActivity *)activity {
  // Get the list of items.
  NSDictionary *userInfo = activity.userInfo;
  NSArray *importedItems = userInfo[kRWTActivityItemsKey];
  
  // Merge it with what we have locally and update UI.
  for (NSString *anItem in importedItems) {
    [self addItemToItemsIfUnique:anItem];
  }
  [[RWTPersistentStore defaultStore] updateStoreWithItems:self.items];
  [[RWTPersistentStore defaultStore] commit];
  [self.tableView reloadData];

  [super restoreUserActivityState:activity];
}

@end
