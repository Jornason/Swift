//
//  AssetCollectionViewCell.h
//  Stitch
//
//  Created by Jack Wu on 2014-06-22.
//
//

@import UIKit;
@class SSCheckMark;
@interface AssetCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView * imageView;
@property (strong, nonatomic) IBOutlet SSCheckMark * checkMark;
@property (assign, nonatomic) NSInteger reuseCount;
@end
