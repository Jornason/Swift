//
//  StitchDetailViewController.m
//  Stitch
//
//  Created by Jack Wu on 2014-06-26.
//
//

#import "StitchDetailViewController.h"
#import "AssetCollectionsViewController.h"
#import "StitchHelper.h"

@interface StitchDetailViewController () <PHPhotoLibraryChangeObserver, AssetPickerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *favoriteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@property (strong, nonatomic) NSMutableArray * stitchAssets;
@end

@implementation StitchDetailViewController

static NSString * const StitchEditSegueID = @"StitchEditSegue";

- (void)dealloc {
  [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self displayImage];
  
  self.editButton.enabled = [self.asset canPerformEditOperation:PHAssetEditOperationContent];
  self.deleteButton.enabled = [self.asset canPerformEditOperation:PHAssetEditOperationDelete];
  self.favoriteButton.enabled = [self.asset canPerformEditOperation:PHAssetEditOperationProperties];
  
  [self updateFavoriteButton];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:StitchEditSegueID]) {
    UINavigationController * nav = (UINavigationController *)segue.destinationViewController;
    AssetCollectionsViewController * destination = (AssetCollectionsViewController *)nav.viewControllers[0];
    destination.delegate = self;
    destination.selectedAssets = self.stitchAssets;
  }
}

- (void)displayImage {
  CGFloat scale = [UIScreen mainScreen].scale;
  CGSize targetSize = CGSizeMake(CGRectGetWidth(self.imageView.bounds) * scale, CGRectGetHeight(self.imageView.bounds) * scale);
  
  PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
  options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
  options.networkAccessAllowed = YES;

  [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
    if (result) {
      self.imageView.image = result;
    }
  }];
}

- (void)updateFavoriteButton {
  if (self.asset.isFavorite) {
    self.favoriteButton.title = @"Unfavorite";
  }
  else {
    self.favoriteButton.title = @"Favorite";
  }
}

#pragma mark - Actions

- (IBAction)favoritePressed:(id)sender {
  [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:self.asset];
    [request setFavorite:![self.asset isFavorite]];
  } completionHandler:^(BOOL success, NSError *error) {
    if (!success) {
      NSLog(@"Error: %@", error);
    }
  }];
}

- (IBAction)deletePressed:(id)sender {
  [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    [PHAssetChangeRequest deleteAssets:@[self.asset]];
  } completionHandler: ^(BOOL success, NSError *error) {
    if (!success) {
      NSLog(@"Error: %@", error);
    }
  }];
}

- (IBAction)editPressed:(id)sender {
  [StitchHelper loadAssetsInStitch:self.asset completion:^(NSMutableArray *assets) {
    self.stitchAssets = assets;
    dispatch_async(dispatch_get_main_queue(), ^{
      [self performSegueWithIdentifier:StitchEditSegueID sender:self];
    });
  }];
}

#pragma mark - AssetPickerDelegate

- (void)assetPickerDidCancel {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)assetPickerDidFinishPickingAssets:(NSMutableArray *)selectedAssets {
  [self dismissViewControllerAnimated:YES completion:nil];
  
  UIImage * stitchImage = [StitchHelper createStitchImageWithAssets:selectedAssets];
  [StitchHelper editStitchContentWith:self.asset image:stitchImage assets:selectedAssets];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
  dispatch_async(dispatch_get_main_queue(), ^{
    PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:self.asset];
    if (changeDetails) {
      if ([changeDetails objectWasDeleted]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
      }
      self.asset = [changeDetails objectAfterChanges];
      if ([changeDetails assetContentChanged]) {
        [self displayImage];
      }
      [self updateFavoriteButton];
    }
  });
}

@end
