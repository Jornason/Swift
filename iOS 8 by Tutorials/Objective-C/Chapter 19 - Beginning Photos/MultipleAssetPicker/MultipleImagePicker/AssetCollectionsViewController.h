//
//  RootTableViewController.h
//  Stitch
//
//  Created by Jack Wu on 2014-06-22.
//
//

@import UIKit;

@protocol AssetPickerDelegate <NSObject>

- (void)assetPickerDidFinishPickingAssets:(NSMutableArray *)selectedAssets;
- (void)assetPickerDidCancel;
@end

@interface AssetCollectionsViewController : UITableViewController

@property (weak, nonatomic) id<AssetPickerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray * selectedAssets;

@end
