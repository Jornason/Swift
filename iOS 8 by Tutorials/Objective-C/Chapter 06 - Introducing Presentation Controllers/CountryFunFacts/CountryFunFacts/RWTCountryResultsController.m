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

#import "RWTCountryResultsController.h"
#import "RWTCountry.h"
#import "RWTCountryTableViewCell.h"

@interface RWTCountryResultsController ()

@end

@implementation RWTCountryResultsController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.filteredCountries = [[NSMutableArray alloc] init];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  [self.tableView registerNib:[UINib nibWithNibName:@"RWTCountryTableViewCell"
                                             bundle:nil]
       forCellReuseIdentifier:@"Cell"];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.filteredCountries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RWTCountryTableViewCell *cell = (RWTCountryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  RWTCountry *country = self.filteredCountries[indexPath.row];
  [cell configureCellForCountry:country];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 246.0;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  [self.delegate searchCountrySelected];
}



#pragma mark - Search Helper

- (void)filterContentForSearchText:(NSString *)searchText {
  // Update the filtered array based on the search text.
  // Remove all objects from the filtered search array
  [self.filteredCountries removeAllObjects];
  
  // Filter the array using NSPredicate
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.countryName contains[c] %@", searchText];
  NSArray *tempArray = [self.countries filteredArrayUsingPredicate:predicate];
  self.filteredCountries = [NSMutableArray arrayWithArray:tempArray];
  
  [self.tableView reloadData];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
  if (!searchController.isActive) {
    return;
  }
  
  [self filterContentForSearchText:searchController.searchBar.text];
}

@end
