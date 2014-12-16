//
//  RootTableViewController.m
//  Stitch
//
//  Created by Jack Wu on 2014-06-22.
//
//

@import Photos;

#import "AssetCollectionsViewController.h"
#import "AssetsViewController.h"

@interface AssetCollectionsViewController ()

@property (strong, nonatomic) NSArray * sectionNames;
@property (strong, nonatomic) PHFetchResult * userFavorites;
@property (strong, nonatomic) PHFetchResult * userAlbums;

@end

@implementation AssetCollectionsViewController

static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

#pragma mark - UIViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    
  if (!self.selectedAssets) {
      self.selectedAssets = [[NSMutableArray alloc] initWithCapacity:6];
  }
  
  [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([PHPhotoLibrary authorizationStatus] ==  PHAuthorizationStatusAuthorized) {
        [self fetchCollections];
        [self.tableView reloadData];
      }
      else {
        [self showNoAccessAlertAndCancel];
      }
    });
  }];

  self.sectionNames = @[@"", @"", @"Albums"];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  AssetsViewController * destination = (AssetsViewController *)segue.destinationViewController;
  
  destination.selectedAssets = self.selectedAssets;
  
  PHFetchOptions * options = [[PHFetchOptions alloc] init];
  options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:true]];
  NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
  if (indexPath.section == 0) {
    // Selected
    destination.assetsFetchResults = nil;
    destination.title = @"Selected";
  }
  else if (indexPath.section == 1) {
    if (indexPath.row == 0) {
      // All Photos
      destination.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
      destination.title = @"All Photos";
    }
    else {
      // Favorites
      PHAssetCollection * favorites = self.userFavorites[indexPath.row - 1];
      destination.assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:favorites options:options];
      destination.title = favorites.localizedTitle;
    }
  }
  else {
    // Albums
    PHAssetCollection * album = self.userAlbums[indexPath.row];
    destination.assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:album options:options];
    destination.title = album.localizedTitle;
  }
}

#pragma mark - Private

- (void)fetchCollections {
  self.userFavorites = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
  self.userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
  
}

- (void)showNoAccessAlertAndCancel {
  UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"No Photo Permissions" message:@"Please grant photo permissions in Settings"  preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    [self cancelPressed:self];
  }]];
  [alert addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
  }]];
  
}

#pragma mark - Actions

- (IBAction)donePressed:(id)sender {
  if ([self.delegate respondsToSelector:@selector(assetPickerDidFinishPickingAssets:)]) {
    [self.delegate assetPickerDidFinishPickingAssets:self.selectedAssets];
  }
}

- (IBAction)cancelPressed:(id)sender {
  if ([self.delegate respondsToSelector:@selector(assetPickerDidCancel)]) {
    [self.delegate assetPickerDidCancel];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.sectionNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    // Selected
    return 1;
  }
  else if (section == 1) {
    // All Photos + Favorites
    return 1 + self.userFavorites.count;
  }
  else {
    // User Albums
    return self.userAlbums.count;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
  cell.detailTextLabel.text = @"";
  if (indexPath.section == 0) {
    // Selected
    cell.textLabel.text = @"Selected";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.selectedAssets.count];
  }
  else if (indexPath.section == 1) {
    if (indexPath.row == 0) {
      // All Photos
      cell.textLabel.text = @"All Photos";
    }
    else {
      // Favorites
      PHAssetCollection * favorites = self.userFavorites[indexPath.row - 1];
      cell.textLabel.text = favorites.localizedTitle;
      if (favorites.estimatedAssetCount != NSNotFound) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)favorites.estimatedAssetCount];
      }
    }
  }
  else {
    // User Albums
    PHAssetCollection * album = self.userAlbums[indexPath.row];
    cell.textLabel.text = album.localizedTitle;
    if (album.estimatedAssetCount != NSNotFound) {
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)album.estimatedAssetCount];
    }
  }
  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return self.sectionNames[section];
}
@end
