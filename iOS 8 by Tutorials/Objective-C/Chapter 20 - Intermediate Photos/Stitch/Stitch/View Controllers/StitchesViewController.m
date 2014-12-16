//
//  RootViewController.m
//  Stitch
//
//  Created by Jack Wu on 2014-06-26.
//
//

#import "StitchesViewController.h"
#import "AssetCell.h"
#import "AssetCollectionsViewController.h"
#import "StitchHelper.h"
#import "StitchDetailViewController.h"

@interface StitchesViewController () <PHPhotoLibraryChangeObserver, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AssetPickerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *noStitchView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createStitchButton;

@property (strong, nonatomic) PHFetchResult * stitches;
@property (strong, nonatomic) PHAssetCollection * stitchesCollection;
@property (assign, nonatomic) CGSize assetThumbnailSize;

@end

@implementation StitchesViewController

static NSString * const StitchesAlbumTitle = @"Stitches";

static NSString * const StitchCellReuseIdentifier = @"StitchCell";
static NSString * const CreateNewStitchSegueID = @"CreateNewStitchSegue";
static NSString * const StitchDetailSegueID = @"StitchDetailSegue";

- (void)dealloc {
  [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
  
  [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    dispatch_async(dispatch_get_main_queue(), ^{
      
    if (status == PHAuthorizationStatusAuthorized) {
      PHFetchOptions * options = [[PHFetchOptions alloc] init];
      options.predicate = [NSPredicate predicateWithFormat:@"title = %@", StitchesAlbumTitle];
      PHFetchResult * collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:options];
      
      if (collections.count) {
        self.stitchesCollection = collections[0];
        self.stitches = [PHAsset fetchAssetsInAssetCollection:self.stitchesCollection options:nil];
        [self.collectionView reloadData];
        [self updateNoStitchView];
      }
      else {
        //Stitches Album does not exist, create it
        __block PHObjectPlaceholder * collectionPlaceholder;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
          PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:StitchesAlbumTitle];
          collectionPlaceholder = collectionChangeRequest.placeholderForCreatedAssetCollection;
        } completionHandler:^(BOOL success, NSError *error) {
          if (!success) {
            NSLog(@"Collection Creation Failed: %@",error);
            return;
          }
          PHFetchResult * collections = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionPlaceholder.localIdentifier] options:nil];
          if (collections.count) {
            self.stitchesCollection = collections[0];
            self.stitches = [PHAsset fetchAssetsInAssetCollection:self.stitchesCollection options:nil];
          }
        }];
      }
    }
    else {
      self.noStitchView.text = @"Please grant Stitch photo access in Settings -> Privacy";
      self.noStitchView.hidden = NO;
      self.createStitchButton.enabled = NO;
      
      UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"No Photo Access" message:@"Please grant Stitch photo access in Settings -> Privacy" preferredStyle:UIAlertControllerStyleAlert];
      [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * alertAction) {
        [self dismissViewControllerAnimated:YES completion:nil];
      } ]];
      [self presentViewController:alert animated:YES completion:nil];
    }
    });
  }];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self updateNoStitchView];
  
  CGFloat scale = [UIScreen mainScreen].scale;
  CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
  self.assetThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
  [self.collectionView reloadData];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  [self.collectionView reloadData];
}

- (void)updateNoStitchView {
  self.noStitchView.hidden = !self.stitches || self.stitches.count > 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:CreateNewStitchSegueID]) {
    UINavigationController * nav = (UINavigationController *)segue.destinationViewController;
    AssetCollectionsViewController * destination = (AssetCollectionsViewController *)nav.viewControllers[0];
    destination.delegate = self;
    destination.selectedAssets = nil;
  }
  else if ([segue.identifier isEqualToString:StitchDetailSegueID]) {
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:sender];
    
    StitchDetailViewController * destination = (StitchDetailViewController *)segue.destinationViewController;
    destination.asset = self.stitches[indexPath.item];
  }
}

#pragma mark - AssetPickerDelegate

- (void)assetPickerDidCancel {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)assetPickerDidFinishPickingAssets:(NSMutableArray *)selectedAssets {
  [self dismissViewControllerAnimated:YES completion:nil];
  
  if (!selectedAssets.count) {
    return;
  }
  
  [StitchHelper createNewStitchWith:selectedAssets inCollection:self.stitchesCollection];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.stitches.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  AssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:StitchCellReuseIdentifier forIndexPath:indexPath];
  
  NSInteger reuseCount = ++cell.reuseCount;
  PHAsset * asset = self.stitches[indexPath.row];
  
  PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
  options.networkAccessAllowed = YES;
  
  [[PHImageManager defaultManager] requestImageForAsset:asset
                                             targetSize:self.assetThumbnailSize
                                            contentMode:PHImageContentModeAspectFill
                                                options:options
                                          resultHandler:^(UIImage * result, NSDictionary * info) {
                                            if (reuseCount == cell.reuseCount) {
                                              cell.imageView.image = result;
                                            }
                                          }];
  
  return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger thumbsPerRow;
  if (collectionView.bounds.size.width < 400) {
    thumbsPerRow = 2;
  }
  else if (collectionView.bounds.size.width < 800) {
    thumbsPerRow = 4;
  }
  else {
    thumbsPerRow = 5;
  }
  
  CGFloat width = collectionView.bounds.size.width / thumbsPerRow;
  CGSize size = {width, width};
  return size;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
  dispatch_async(dispatch_get_main_queue(), ^{
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.stitches];
    if (collectionChanges) {
      
      self.stitches = [collectionChanges fetchResultAfterChanges];
      
      if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
        [self.collectionView reloadData];
        
      } else {
        // if we have incremental diffs, tell the collection view to animate insertions and deletions
        [self.collectionView performBatchUpdates:^{
          NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
          if (removedIndexes.count) {
            [self.collectionView deleteItemsAtIndexPaths:[self indexPathsFromIndexes:removedIndexes WithSection:0]];
          }
          NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
          if (insertedIndexes.count) {
            [self.collectionView insertItemsAtIndexPaths:[self indexPathsFromIndexes:insertedIndexes WithSection:0]];
          }
          NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
          if (changedIndexes.count) {
            [self.collectionView reloadItemsAtIndexPaths:[self indexPathsFromIndexes:changedIndexes WithSection:0]];
          }
        } completion:NULL];
      }
    }
  });
}

- (NSArray *)indexPathsFromIndexes:(NSIndexSet*)indexSet WithSection:(NSUInteger)section {
  NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:indexSet.count];
  [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
  }];
  return indexPaths;
}


@end
