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

#import "ThumbnailCollectionViewController.h"
#import "ThumbnailCell.h"

@import S3Kit;

@interface ThumbnailCollectionViewController ()
@property (strong, nonatomic) BucketInfo* s3Bucket;
@end

@implementation ThumbnailCollectionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.collectionView.backgroundColor = [UIColor whiteColor];
  
  self.s3Bucket = [[BucketInfo alloc] init];
  [self.s3Bucket load:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.collectionView reloadData];
    });
  } thumbnailBlock:^(NSIndexPath *indexPath) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    });
  }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self.s3Bucket fileCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  ThumbnailCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbCell" forIndexPath:indexPath];
  S3Image* imageWrapper = [self.s3Bucket objAtIndex:indexPath];
  [cell setImageURL:imageWrapper.url];
  
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
  S3Image* imageWrapper = [self.s3Bucket objAtIndex:indexPath];
  if (self.delegate) {
    [self.delegate didSelectImage:imageWrapper];
  }
}

@end
