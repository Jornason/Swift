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
#import "RWTDetailViewController.h"
#import "RWTWeatherData.h"
#import "RWTCityTableViewCell.h"

@interface RWTMasterViewController ()

@property RWTWeatherData *weatherData;
@end

@implementation RWTMasterViewController

- (void)awakeFromNib
{
  [super awakeFromNib];
  if (!self.weatherData) {
    self.weatherData = [RWTWeatherData loadFromDefaultPList];
  }
  
  [self prepareNavigationBarAppearance];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.detailViewController = (RWTDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  self.detailViewController.cityWeather = self.weatherData.cities[0];
  self.title = @"Cities";
  
  
  self.tableView.estimatedRowHeight = 200;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    RWTCityWeather *cityWeather = self.weatherData.cities[indexPath.row];
    RWTDetailViewController *controller = (RWTDetailViewController *)[[segue destinationViewController] topViewController];
    controller.cityWeather = cityWeather;
    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
  }
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.weatherData.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RWTCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
  
  RWTCityWeather *cityWeather = self.weatherData.cities[indexPath.row];
  [cell prepareCellForCityWeather:cityWeather];
  return cell;
}


#pragma mark - Utility methods
- (void)prepareNavigationBarAppearance {
  
  // Vertically regular
  UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
  UITraitCollection *verticallyRegular = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassRegular];
  [UINavigationBar appearanceForTraitCollection:verticallyRegular].titleTextAttributes = @{NSFontAttributeName : font};
  
  // Vertically compact
  UITraitCollection *verticallyCompact = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassCompact];
  font = [font fontWithSize:20.0];
  [UINavigationBar appearanceForTraitCollection:verticallyCompact].titleTextAttributes = @{NSFontAttributeName : font };
}

@end
