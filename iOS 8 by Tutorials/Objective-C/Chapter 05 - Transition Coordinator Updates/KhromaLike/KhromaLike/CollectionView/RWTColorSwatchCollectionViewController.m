/*
 * Copyright (c) 2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "RWTColorSwatchCollectionViewController.h"
#import "RWTColorSwatchList.h"
#import "RWTColorSwatchCollectionViewCell.h"

@interface RWTColorSwatchCollectionViewController ()

@property (strong, nonatomic) RWTColorSwatchList *swatchList;
@property (assign, nonatomic) CGAffineTransform currentCellContentTransform;

@end


@implementation RWTColorSwatchCollectionViewController

static NSString * const reuseIdentifier = @"ColorSwatchCell";

- (void)viewWillAppear:(BOOL)animated {
  if(!self.swatchList) {
    self.swatchList = [RWTColorSwatchList defaultColorSwatchList];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
  }
  self.currentCellContentTransform = CGAffineTransformIdentity;
  [super viewWillAppear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  // Pass to child VCs
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  
  // Extract the relevant transforms
  CGAffineTransform targetTransform = [coordinator targetTransform];
  CGAffineTransform invertedTransform = CGAffineTransformInvert(targetTransform);
  
  [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    // Purposefully empty
  } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    // Rotate the view's layer
    self.view.layer.transform = CATransform3DConcat(self.view.layer.transform, CATransform3DMakeAffineTransform(invertedTransform));
    // Update the bounds of the view (switching width and height)
    if (ABS(atan2(targetTransform.b, targetTransform.a) / M_PI) < 0.9) {
      self.view.bounds = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
    }
    
    // Animate the cells individually
    self.currentCellContentTransform = CGAffineTransformConcat(self.currentCellContentTransform, targetTransform);
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:0 animations:^{
      for(UICollectionViewCell *cell in self.collectionView.visibleCells) {
        cell.contentView.transform = self.currentCellContentTransform;
      }
    } completion:NULL];
  }];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  if([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    // Find the restrictive dimension
    CGFloat minDimension = MIN(CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds));
    CGSize newSize = CGSizeMake(minDimension, minDimension);
    if(!CGSizeEqualToSize(newSize, flowLayout.itemSize)) {
      // Reset the size of the cells
      flowLayout.itemSize = newSize;
      // Get the flow layout to re-layout.
      [flowLayout invalidateLayout];
    }
  }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.swatchList.colorSwatches.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                         forIndexPath:indexPath];
  
  // Reset the trainsform on the content
  cell.contentView.transform = CGAffineTransformIdentity;
  
  // Configure the cell
  if([cell isKindOfClass:[RWTColorSwatchCollectionViewCell class]]) {
    RWTColorSwatchCollectionViewCell *swatchCell = (RWTColorSwatchCollectionViewCell *)cell;
    RWTColorSwatch *swatch = self.swatchList.colorSwatches[indexPath.item];
    [swatchCell resetCellForColorSwatch:swatch];
  }
  
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
  cell.contentView.transform = self.currentCellContentTransform;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  // Notify the selection delegate that a selection has been made
  if(self.swatchSelectionDelegate &&
     [self.swatchSelectionDelegate respondsToSelector:@selector(didSelectColorSwatch:sender:)]) {
    RWTColorSwatch *selectedSwatch = self.swatchList.colorSwatches[indexPath.item];
    [self.swatchSelectionDelegate didSelectColorSwatch:selectedSwatch sender:self];
  }
}

@end
