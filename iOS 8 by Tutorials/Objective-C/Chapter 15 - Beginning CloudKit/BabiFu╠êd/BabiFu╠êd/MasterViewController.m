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


@import CoreLocation;

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "Model.h"

@interface MasterViewController () <ModelDelegate, CLLocationManagerDelegate>

@property Model* model;
@property (strong, nonatomic) CLLocationManager* locationManager;

@end

@implementation MasterViewController

- (void)awakeFromNib {
  [super awakeFromNib];
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
   self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
  [self setupLocationManager];

  self.model = [Model model];
  self.model.delegate = self;
  [self.model refresh];
  
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self.model action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
  
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Establishment* e = self.model.items[indexPath.row];
    [(DetailViewController *)[[segue destinationViewController] topViewController] setDetailItem:e];
  }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.model.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EstablishmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
  Establishment* e = self.model.items[indexPath.row];
  cell.titleLabel.text = [e name];
 
  [e fetchRating:^(double rating, BOOL isUser) {
    cell.starRating.rating = rating;
    cell.starRating.emptyColor = isUser ? [UIColor yellowColor] : [UIColor whiteColor];
    cell.starRating.solidColor = isUser ? [UIColor yellowColor] : [UIColor whiteColor];
  }];
  
  NSMutableArray* badges = [NSMutableArray array];
  if (e.changingTableType & ChangingTableTypeMens) {
    [badges addObject:[UIImage imageNamed:@"man"]];
  }
  if (e.changingTableType & ChangingTableTypeWomens) {
    [badges addObject:[UIImage imageNamed:@"woman"]];
  }
  if (e.seatingType & SeatingTypeHighChair) {
    [badges addObject:[UIImage imageNamed:@"highchair"]];
  }
  if (e.seatingType & SeatingTypeBooster) {
    [badges addObject:[UIImage imageNamed:@"booster"]];
  }
  [cell setBadges:badges];
  
  [e loadCoverPhoto:^(UIImage *photo) {
    dispatch_async(dispatch_get_main_queue(), ^{
      cell.coverPhotoView.image = photo;
    });
  }];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    Establishment* object = self.model.items[indexPath.row];
    self.detailViewController.detailItem = object;
  }
}

- (void) modelUpdated {
  [self.refreshControl endRefreshing];
  [self.tableView reloadData];
}

- (void) modelUpdatedAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) errorUpdatingModel:(NSError *)error {
  [self.refreshControl endRefreshing];
  [[[UIAlertView alloc] initWithTitle:@"Error loading data" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - location

- (void) setupLocationManager {
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
  self.locationManager.distanceFilter = 500; //0.5km
  self.locationManager.delegate = self;
  
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
  if (status == kCLAuthorizationStatusNotDetermined) {
    [self.locationManager requestWhenInUseAuthorization];
  } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self.locationManager startUpdatingLocation];
  } else {
    //use denied location
  }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status == kCLAuthorizationStatusNotDetermined) {
    [self.locationManager requestWhenInUseAuthorization];
  } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
    [self.locationManager startUpdatingLocation];
  } else {
    //use denied location
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  CLLocation* location = [locations lastObject];
  [self.model refreshEstablishmentsNear:location within:3];
}
@end
