//
//  StitchCreator.h
//  Stitch
//
//  Created by Jack Wu on 2014-06-29.
//
//

@import Photos;

static NSString * const StitchAdjustmentFormatIdentifier = @"com.jackwu.stitch.adjustmentFormatID";

@interface StitchHelper : NSObject

+ (void)createNewStitchWith:(NSArray *)assets inCollection:(PHAssetCollection *)collection;

+ (void)editStitchContentWith:(PHAsset *)stitch image:(UIImage *)image assets:(NSArray *)assets;

+ (void)loadAssetsInStitch:(PHAsset *)stitch completion:(void(^)(NSMutableArray *assets))completion;

+ (UIImage *)createStitchImageWithAssets:(NSArray *)assets;

@end
