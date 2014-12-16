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

#import "RWTCollectionViewLayout.h"

@interface RWTCollectionViewLayout ()

@property (strong, nonatomic) NSMutableArray *insertIndexPaths;
@property (strong, nonatomic) NSMutableArray *deleteIndexPaths;
@property (assign, nonatomic) CGPoint center;

@end

@implementation RWTCollectionViewLayout

- (instancetype)initWithTraitCollection:(UITraitCollection *)traitCollection {
  self = [super init];
  if (self) {
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    
    
    if (traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
      self.itemSize = CGSizeMake(359.0, 208.0);
      self.sectionInset = UIEdgeInsetsMake(40.0, 20.0, 40.0, 20.0);
    } else {
      self.itemSize = CGSizeMake(145.0, 84.0);
      self.sectionInset = UIEdgeInsetsMake(20.0, 10.0, 20.0, 10.0);
    }
    
    
    self.minimumInteritemSpacing = 10.0;
    self.minimumLineSpacing = 10.0;
    
    self.headerReferenceSize = CGSizeZero;
    self.footerReferenceSize = CGSizeZero;
    
  }
  return self;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
  [super prepareForCollectionViewUpdates:updateItems];
  
  self.deleteIndexPaths = [NSMutableArray array];
  self.insertIndexPaths = [NSMutableArray array];
  
  for (UICollectionViewUpdateItem *update in updateItems) {
    if (update.updateAction == UICollectionUpdateActionDelete) {
      [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
    } else if (update.updateAction == UICollectionUpdateActionInsert) {
      [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
    }
  }
}

- (void)finalizeCollectionViewUpdates {
  [super finalizeCollectionViewUpdates];
  
  self.deleteIndexPaths = nil;
  self.insertIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
  UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
  
  if ([self.insertIndexPaths containsObject:itemIndexPath]) {
    if (!attributes) {
      attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    }
    
    CGFloat cellWidth = self.itemSize.width;
    CGFloat centerX = (itemIndexPath.row % 2) ? self.collectionView.bounds.size.width + cellWidth : -cellWidth;
    CGPoint center = attributes.center;
    center.x = centerX;
    
    attributes.center = center;
  }
  
  return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
  UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
  
  if ([self.deleteIndexPaths containsObject:itemIndexPath]) {
    if (!attributes) {
      attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    }
    
    CGFloat cellWidth = self.itemSize.width;
    CGFloat centerX = (itemIndexPath.row % 2) ? self.collectionView.bounds.size.width + cellWidth : -cellWidth;
    CGPoint center = attributes.center;
    center.x = centerX;
    
    attributes.center = center;
  }
  
  return attributes;
}

@end
