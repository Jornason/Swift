//
//  AssetCollectionViewCell.m
//  Stitch
//
//  Created by Jack Wu on 2014-06-22.
//
//

#import "AssetCell.h"
#import "SSCheckMark.h"

@implementation AssetCell

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  self.imageView.highlighted = selected;
  if (self.checkMark) {
    self.checkMark.hidden = !selected;
  }
}

@end
