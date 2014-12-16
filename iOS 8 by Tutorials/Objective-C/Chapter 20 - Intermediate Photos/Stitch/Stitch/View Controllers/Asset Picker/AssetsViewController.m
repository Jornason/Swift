//
//  AssetCollectionViewController.m
//  Stitch
//
//  Created by Jack Wu on 2014-06-22.
//
//

#import "AssetsViewController.h"
#import "AssetCell.h"

@interface AssetsViewController () <PHPhotoLibraryChangeObserver>
@property (strong, nonatomic) PHCachingImageManager * imageManager;
@property (strong, nonatomic) NSMutableArray * cachingIndexes;
@property (assign, nonatomic) CGFloat lastCacheFrameCenter;

@property (assign, nonatomic) CGSize assetThumbnailSize;
@property (strong, nonatomic) dispatch_queue_t cacheQueue;

@end

@implementation AssetsViewController

static NSString * const AssetCellReuseIdentifier = @"AssetCell";

#pragma mark - UIViewController

- (void)dealloc {
  [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
  self.collectionView.allowsMultipleSelection = YES;
  
  self.imageManager = [[PHCachingImageManager alloc] init];
  self.cachingIndexes = [[NSMutableArray alloc] init];
  self.cacheQueue = dispatch_queue_create("cacheQueue", DISPATCH_QUEUE_SERIAL);
  [self resetCache];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  CGFloat scale = [UIScreen mainScreen].scale;
  CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
  self.assetThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
  
  [self.collectionView reloadData];
  
  [self updateSelectedItems];
  [self updateCache];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  [self.collectionView reloadData];
  [self updateSelectedItems];
}

- (PHAsset *)currentAssetAtIndex:(NSInteger)index {
  if (self.assetsFetchResults) {
    return self.assetsFetchResults[index];
  }
  else {
    return self.selectedAssets[index];
  }
}

- (void)updateSelectedItems {
  if (self.assetsFetchResults) {
    for (PHAsset * asset in self.selectedAssets) {
      NSUInteger index = [self.assetsFetchResults indexOfObject:asset];
      if (index != NSNotFound) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
      }
    }
  }
  else {
    //Select all
    for (NSInteger i = 0; i < self.selectedAssets.count; i++) {
      NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
      [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
  }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
  PHAsset * asset = [self currentAssetAtIndex:indexPath.item];
  [self.selectedAssets removeObject:asset];
  if (!self.assetsFetchResults) {
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
  }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  PHAsset * asset = [self currentAssetAtIndex:indexPath.item];
  [self.selectedAssets addObject:asset];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  if (self.assetsFetchResults) {
    return self.assetsFetchResults.count;
  }
  else {
    return self.selectedAssets.count;
  }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  AssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AssetCellReuseIdentifier forIndexPath:indexPath];
  
  NSInteger reuseCount = ++cell.reuseCount;
  PHAsset * asset = [self currentAssetAtIndex:indexPath.item];
  
  PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
  options.networkAccessAllowed = YES;
  
  [self.imageManager requestImageForAsset:asset
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
    thumbsPerRow = 4;
  }
  else if (collectionView.bounds.size.width < 600) {
    thumbsPerRow = 7;
  }
  else if (collectionView.bounds.size.width < 800) {
    thumbsPerRow = 8;
  }
  else {
    thumbsPerRow = 10;
  }
  
  CGFloat width = collectionView.bounds.size.width / thumbsPerRow;
  CGSize size = {width, width};
  return size;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  dispatch_async(self.cacheQueue, ^{
    [self updateCache];
  });
}

#pragma mark - Caching

- (void)resetCache {
  [self.imageManager stopCachingImagesForAllAssets];
  [self.cachingIndexes removeAllObjects];
  self.lastCacheFrameCenter = 0;
}

- (void)updateCache {
  CGFloat currentFrameCenter = CGRectGetMidY(self.collectionView.bounds);
  if (fabs(currentFrameCenter - self.lastCacheFrameCenter) < CGRectGetHeight(self.collectionView.bounds)/3) {
    // Haven't scrolled far enough yet
    return;
  }
  self.lastCacheFrameCenter = currentFrameCenter;
  
  static NSInteger numOffscreenAssetsToCache = 40;
  
  NSArray * visibleIndexes = [self.collectionView.indexPathsForVisibleItems sortedArrayUsingSelector:@selector(compare:)];
  
  if (!visibleIndexes.count) {
    [self.imageManager stopCachingImagesForAllAssets];
    return;
  }
  
  NSInteger firstItemToCache = ((NSIndexPath *)visibleIndexes[0]).item - numOffscreenAssetsToCache/2;
  firstItemToCache = MAX(firstItemToCache, 0);
  
  NSInteger lastItemToCache = ((NSIndexPath *)[visibleIndexes lastObject]).item + numOffscreenAssetsToCache/2;
  if (self.assetsFetchResults) {
    lastItemToCache = MIN(lastItemToCache, self.assetsFetchResults.count - 1);
  }
  else {
    lastItemToCache = MIN(lastItemToCache, self.selectedAssets.count - 1);
  }
  
  NSMutableArray * indexesToStopCaching = [[NSMutableArray alloc] init];
  NSMutableArray * indexesToStartCaching = [[NSMutableArray alloc] init];
  
  PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
  options.networkAccessAllowed = YES;
  
  // Stop caching items we scrolled past
  for (NSIndexPath * index in self.cachingIndexes) {
    if (index.item < firstItemToCache || index.item > lastItemToCache) {
      [indexesToStopCaching addObject:index];
    }
  }
  [self.cachingIndexes removeObjectsInArray:indexesToStopCaching];
  
  [self.imageManager stopCachingImagesForAssets:[self assetsAtIndexPaths:indexesToStopCaching]
                                     targetSize:self.assetThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:options];
  
  // Start caching new items in range
  for (NSInteger i = firstItemToCache; i < lastItemToCache; i++) {
    NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
    if (![self.cachingIndexes containsObject:index]) {
      [indexesToStartCaching addObject:index];
      [self.cachingIndexes addObject:index];
    }
  }
  
  [self.imageManager startCachingImagesForAssets:[self assetsAtIndexPaths:indexesToStartCaching]
                                      targetSize:self.assetThumbnailSize
                                     contentMode:PHImageContentModeAspectFill
                                         options:options];
  
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
  if (!indexPaths.count) {
    return nil;
  }
  
  NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
  
  for (NSIndexPath *indexPath in indexPaths) {
    PHAsset *asset = [self currentAssetAtIndex:indexPath.item];
    [assets addObject:asset];
  }
  
  return assets;
}

#pragma mark - PHPhotLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
  dispatch_async(dispatch_get_main_queue(), ^{
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges) {
      
      self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
      
      if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
        [self.collectionView reloadData];
        
      }
      else {
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
      [self resetCache];
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
