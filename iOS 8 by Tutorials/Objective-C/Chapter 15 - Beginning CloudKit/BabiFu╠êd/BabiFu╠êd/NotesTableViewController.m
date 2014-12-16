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

@import CloudKit;

#import "NotesTableViewController.h"

#import "Model.h"
#import "NotesCell.h"

@interface NotesTableViewController ()
@property (strong, nonatomic) NSArray* notes;
@end

@implementation NotesTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  _notes = @[];
  
  __weak NotesTableViewController* weakSelf = self;
  [[Model model] fetchNotes:^(NSArray *notes, NSError *error) {
    if (!error) {
      weakSelf.notes = notes;
      [weakSelf.tableView reloadData];
    }
  }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.notes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NotesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotesCell" forIndexPath:indexPath];

  NSDictionary* record = self.notes[indexPath.row];
  cell.notesLabel.text = record[@"Note"];
  
 Establishment* establishment  = record[@"Establishment"];
  if (establishment) {
    cell.titleLabel.text = establishment.name;
    [establishment loadCoverPhoto:^(UIImage *photo) {
      dispatch_async(dispatch_get_main_queue(), ^{
        cell.thumbImageView.image = photo;
      });
    }];
  } else {
    cell.thumbImageView.image = nil;
    cell.titleLabel.text = @"???";
  }
  
  return cell;
}


@end
