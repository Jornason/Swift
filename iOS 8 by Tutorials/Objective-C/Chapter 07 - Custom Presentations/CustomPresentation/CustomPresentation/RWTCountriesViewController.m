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

#import "RWTCountriesViewController.h"
#import "RWTCollectionViewCell.h"
#import "RWTCountry.h"
#import "RWTOverlayViewController.h"
#import "RWTSelectionObject.h"
#import "RWTSimpleTransitioner.h"
#import "RWTAwesomeTransitioner.h"
#import "RWTCollectionViewLayout.h"

@interface RWTCountriesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTrailingConstraint;
@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) RWTSelectionObject *selectionObject;
@property (strong, nonatomic) RWTSimpleTransitioningDelegate *simpleTransitionDelegate;
@property (strong, nonatomic) RWTAwesomeTransitioningDelegate *awesomeTransitionDelegate;

@end

@implementation RWTCountriesViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.imageView.image = [UIImage imageNamed:@"BackgroundImage"];
  self.countries = [RWTCountry countries];
  
  RWTCollectionViewLayout *flowLayout = [[RWTCollectionViewLayout alloc] initWithTraitCollection:self.traitCollection];
  [flowLayout invalidateLayout];
  [self.collectionView setCollectionViewLayout:flowLayout animated:NO];
  [self.collectionView reloadData];
}


#pragma mark -

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  if (self.collectionView.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    // Increase leading and trailing constraints to center cells
    CGFloat padding = 0.0;
    CGFloat viewWidth = self.view.frame.size.width;
    if (viewWidth > 320.0) {
      padding = (viewWidth - 320.0) / 2.0;
    }
    
    self.collectionViewLeadingConstraint.constant = padding;
    self.collectionViewTrailingConstraint.constant = padding;
  }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.countries.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  RWTCollectionViewCell *cell = (RWTCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"RWTCollectionViewCell" forIndexPath:indexPath];
  
  RWTCountry *country = self.countries[indexPath.row];
  cell.imageView.image = [UIImage imageNamed:country.imageName];
  
  // Determine if it needs to be hidden for insertion animation
  if (self.selectionObject && [self.selectionObject.country.countryName isEqualToString:country.countryName]) {
    cell.imageView.hidden = self.selectionObject.country.isHidden;
  } else {
    cell.imageView.hidden = NO;
  }
  
  return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
  // Toggle this for the displaying either the simple or awesome overlay
  
  //[self showSimpleOverlayForIndexPath:indexPath];
  [self showAwesomeOverlayForIndexPath:indexPath];
  
}

- (void)showSimpleOverlayForIndexPath:(NSIndexPath *)indexPath {
  RWTCountry *country = self.countries[indexPath.row];
  
  RWTOverlayViewController *overlay = [[RWTOverlayViewController alloc] initWithCountry:country];
  
  self.simpleTransitionDelegate = [[RWTSimpleTransitioningDelegate alloc] init];
  self.transitioningDelegate = self.simpleTransitionDelegate;
  
  overlay.transitioningDelegate = self.simpleTransitionDelegate;
  
  [self presentViewController:overlay animated:YES completion:nil];
}

- (void)showAwesomeOverlayForIndexPath:(NSIndexPath *)indexPath {
  RWTCountry *country = self.countries[indexPath.row];
  country.isHidden = YES;
  
  RWTOverlayViewController *overlay = [[RWTOverlayViewController alloc] initWithCountry:country];
  
  RWTCollectionViewCell *selectedCell = (RWTCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
  
  CGRect rect = selectedCell.frame;
  CGPoint origin = [self.view convertPoint:rect.origin fromView:selectedCell.superview];
  rect.origin = origin;
  
  self.selectionObject = [[RWTSelectionObject alloc] initWithCountry:country cellIndexPath:indexPath originalCellPosition:rect];
  
  self.awesomeTransitionDelegate = [[RWTAwesomeTransitioningDelegate alloc] initWithSelectedObject:self.selectionObject];
  self.transitioningDelegate = self.awesomeTransitionDelegate;
  
  [overlay setTransitioningDelegate:self.awesomeTransitionDelegate];
  
  [self presentViewController:overlay animated:YES completion:nil];
  
  
  // Animation fades out the imageView so there is no flicker from setting
  // it to hidden while the imageView is added to the presentation controller.
  [UIView animateWithDuration:0.1 animations:^{
    selectedCell.imageView.alpha = 0.0;
  }];
}

- (NSMutableArray *)indexPathsForAllItems {
  NSUInteger count = self.countries.count;
  
  NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
  for (NSUInteger index = 0; index < count; index++) {
    [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
  }
  
  return indexPaths;
}

- (void)changeCellSpacingForPresentation:(BOOL)presentation {
  
  if (presentation) {
    
    NSMutableArray *indexPaths = [self indexPathsForAllItems];
    
    self.countries = [NSArray array];
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
    
  } else {
    
    self.countries = [RWTCountry countries];
    
    NSMutableArray *indexPaths = [self indexPathsForAllItems];
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
  }
  
  [self.view layoutIfNeeded];
}

- (void)hideImage:(BOOL)hidden atIndexPath:(NSIndexPath *)indexPath {
  if (self.selectionObject) {
    self.selectionObject.country.isHidden = hidden;
  }
  
  if (indexPath.row < self.countries.count) {
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
  }
}

- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)indexPath {
  RWTCollectionViewCell *cell = (RWTCollectionViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
  return cell.frame;
}

@end
