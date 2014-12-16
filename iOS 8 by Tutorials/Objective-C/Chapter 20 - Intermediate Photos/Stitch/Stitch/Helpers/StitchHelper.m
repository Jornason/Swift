//
//  StitchCreator.m
//  Stitch
//
//  Created by Jack Wu on 2014-06-29.
//
//

@import CoreGraphics;
@import UIKit;
#import "StitchHelper.h"

#define StitchWidth 900
#define MaxPhotosPerStitch 6

@implementation StitchHelper

+ (void)createNewStitchWith:(NSArray *)assets inCollection:(PHAssetCollection *)collection {
  UIImage * stitchImage = [StitchHelper createStitchImageWithAssets:assets];
  
  __block PHObjectPlaceholder * stitchPlaceholder;
  [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    PHAssetChangeRequest * assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:stitchImage];
    
    stitchPlaceholder = assetChangeRequest.placeholderForCreatedAsset;
    
    PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection assets:nil];
    [assetCollectionChangeRequest addAssets:@[stitchPlaceholder]];
    
  } completionHandler:^(BOOL success, NSError *error) {
    // Fetch the new asset and add the adjustment data to it
    PHFetchResult * fetch = [PHAsset fetchAssetsWithLocalIdentifiers:@[stitchPlaceholder.localIdentifier] options:nil];
    PHAsset * newStitch = fetch[0];
    [self editStitchContentWith:newStitch image:stitchImage assets:assets];
  }];
}

+ (void)editStitchContentWith:(PHAsset *)stitch image:(UIImage *)image assets:(NSArray *)assets {
  NSData * stitchJPEG = UIImageJPEGRepresentation(image, 0.9);
  NSArray * assetsIDs = [assets valueForKey:@"localIdentifier"];
  NSData * assetsData = [NSKeyedArchiver archivedDataWithRootObject:assetsIDs];
  
  [stitch requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
    PHAdjustmentData * adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:StitchAdjustmentFormatIdentifier formatVersion:@"1.0" data:assetsData];
    
    PHContentEditingOutput * editingOutput = [[PHContentEditingOutput alloc] initWithContentEditingInput:contentEditingInput];
    editingOutput.adjustmentData = adjustmentData;
    [stitchJPEG writeToURL:editingOutput.renderedContentURL atomically:YES];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
      PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:stitch];
      request.contentEditingOutput = editingOutput;
    } completionHandler:^(BOOL success, NSError *error) {
      if (!success) {
        NSLog(@"Error: %@", error);
      }
    }];
  }];
}

+ (void)loadAssetsInStitch:(PHAsset *)stitch completion:(void(^)(NSMutableArray *assets))completion {
  PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
  [options setCanHandleAdjustmentData:^BOOL(PHAdjustmentData *adjustmentData) {
    return [adjustmentData.formatIdentifier isEqualToString:StitchAdjustmentFormatIdentifier] && [adjustmentData.formatVersion isEqualToString:@"1.0"];
  }];
  
  [stitch requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
    if (contentEditingInput.adjustmentData) {
      NSArray * stitchAssetIDs = [NSKeyedUnarchiver unarchiveObjectWithData:contentEditingInput.adjustmentData.data];
      PHFetchResult * stitchAssetsFetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:stitchAssetIDs options:nil];
      
      NSMutableArray *stitchAssets = [[NSMutableArray alloc] initWithCapacity:stitchAssetsFetchResult.count];
      [stitchAssetsFetchResult enumerateObjectsUsingBlock:^(PHAsset * obj, NSUInteger idx, BOOL *stop) {
        [stitchAssets addObject:obj];
        completion(stitchAssets);
      }];
    }
    else {
      completion(nil);
    }
  }];
}

+ (UIImage *)createStitchImageWithAssets:(NSArray *)assets {
  NSInteger assetCount = assets.count;
  
  if (!assetCount) {
    return nil;
  }
  
  if (assetCount > MaxPhotosPerStitch) {
    assetCount = MaxPhotosPerStitch;
  }
  
  NSArray * placementRects = [self placementRectsForAssetCount:assetCount];
  
  CGFloat deviceScale = [UIScreen mainScreen].scale;
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(StitchWidth, StitchWidth), YES, deviceScale);
  
  PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
  options.synchronous = YES;
  options.resizeMode = PHImageRequestOptionsResizeModeExact;
  options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
  
  for (int i = 0; i < assetCount; i++) {
    @autoreleasepool {
      PHAsset * asset = assets[i];
      CGRect rect = [placementRects[i] CGRectValue];
      CGSize targetSize = CGSizeMake(CGRectGetWidth(rect)*deviceScale, CGRectGetHeight(rect)*deviceScale);
      [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (!CGSizeEqualToSize(result.size, targetSize)) {
          result = [self cropImage:result toSize:targetSize];
        }
        [result drawInRect:rect];
      }];
    }
  }
  
  UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return result;
}

+ (NSArray *)placementRectsForAssetCount:(NSInteger)count {
  NSMutableArray * rects = [[NSMutableArray alloc] initWithCapacity:count];
  
  NSInteger evenCount;
  NSInteger oddCount;
  if (count % 2 == 0) {
    evenCount = count;
    oddCount = 0;
  }
  else {
    oddCount = 1;
    evenCount = count - oddCount;
  }
  
  CGFloat rectHeight = StitchWidth / (evenCount / 2 + oddCount);
  CGFloat evenWidth = StitchWidth / 2;
  CGFloat oddWidth = StitchWidth;
  
  for (int i = 0; i < evenCount; i++) {
    CGRect rect = CGRectMake(i%2 * evenWidth, i/2 * rectHeight, evenWidth, rectHeight);
    [rects addObject:[NSValue valueWithCGRect:rect]];
  }
  
  if (oddCount) {
    CGRect rect = CGRectMake(0, evenCount/2 * rectHeight, oddWidth, rectHeight);
    [rects addObject:[NSValue valueWithCGRect:rect]];
  }
  
  return rects;
}

+ (UIImage *)cropImage:(UIImage*)image toSize:(CGSize)size {
  CGFloat ratio = MIN(image.size.width / size.width, image.size.height / size.height);

  CGSize newSize = {image.size.width / ratio, image.size.height / ratio};
  CGPoint offset = {0.5 * (size.width - newSize.width), 0.5 * (size.height - newSize.height)};
  CGRect rect = {offset, newSize};
  
  UIGraphicsBeginImageContext(size);
  [image drawInRect:rect];
  UIImage * output = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return output;
}

@end
