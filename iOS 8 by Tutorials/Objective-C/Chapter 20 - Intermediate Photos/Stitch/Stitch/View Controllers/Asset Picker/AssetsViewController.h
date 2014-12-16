//
//  AssetCollectionViewController.h
//  Stitch
//
//  Created by Jack Wu on 2014-06-22.
//
//

@import UIKit;
@import Photos;

@interface AssetsViewController : UICollectionViewController

@property (strong, nonatomic) PHFetchResult *assetsFetchResults;

@property (weak, nonatomic) NSMutableArray * selectedAssets;


@end
