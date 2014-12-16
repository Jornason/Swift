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

#import "RWTCountryListViewController.h"
#import "RWTCountryDetailViewController.h"
#import "RWTCountryResultsController.h"
#import "RWTCountry.h"
#import "RWTCountryTableViewCell.h"

@interface RWTCountryListViewController () <RWTCountryResultsControllerDelegate>

@property (strong, nonatomic) UISearchController *searchController;

@property NSArray *countries;

@end

@implementation RWTCountryListViewController

- (void)awakeFromNib {
  [super awakeFromNib];
  self.clearsSelectionOnViewWillAppear = NO;
  self.preferredContentSize = CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"Countries";
  [self loadData];
  
  NSArray *controllers = self.splitViewController.viewControllers;
  if (controllers.count == 1) {
    self.countryDetailViewController = [[RWTCountryDetailViewController alloc] init];
  } else {
    self.countryDetailViewController = (RWTCountryDetailViewController *)[self.splitViewController.viewControllers[controllers.count - 1] topViewController];
  }
  
  
  [self addNewSearchBar];
  
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  
  [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (void)loadData {
  self.countries = [RWTCountry countries];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    
    if (self.searchController.isActive) {
      RWTCountryResultsController *resultsController = (RWTCountryResultsController *)self.searchController.searchResultsController;
      NSIndexPath *indexPath = [resultsController.tableView indexPathForSelectedRow];
      RWTCountry *country = resultsController.filteredCountries[indexPath.row];
      [(RWTCountryDetailViewController *)[[segue destinationViewController] topViewController] setCountry:country];
    } else {
      NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      RWTCountry *country = self.countries[indexPath.row];
      [(RWTCountryDetailViewController *)[[segue destinationViewController] topViewController] setCountry:country];
    }
  }
}

- (void)addNewSearchBar {
  RWTCountryResultsController *resultsController = [[RWTCountryResultsController alloc] init];
  resultsController.countries = self.countries;
  resultsController.delegate = self;
  
  self.searchController = [[UISearchController alloc] initWithSearchResultsController:resultsController];
  self.searchController.searchResultsUpdater = resultsController;
  
  self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x,
                                                     self.searchController.searchBar.frame.origin.y,
                                                     self.searchController.searchBar.frame.size.width,
                                                     44.0); // otherwise the height is 0.0 - bug ?
  
  self.tableView.tableHeaderView = self.searchController.searchBar;
  self.definesPresentationContext = YES;
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RWTCountryTableViewCell *cell = (RWTCountryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  RWTCountry *country = self.countries[indexPath.row];
  [cell configureCellForCountry:country];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  RWTCountry *country = self.countries[indexPath.row];
  self.countryDetailViewController.country = country;
}


#pragma mark - RWTCountryResultsControllerDelegate

- (void)searchCountrySelected {
  [self performSegueWithIdentifier:@"showDetail" sender:nil];
}


@end
