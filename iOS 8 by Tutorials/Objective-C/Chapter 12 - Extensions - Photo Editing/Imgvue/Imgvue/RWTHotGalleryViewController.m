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

#import "RWTHotGalleryViewController.h"
#import "RWTImgurService.h"
#import "RWTImgurImage.h"
#import "RWTImageCollectionViewCell.h"
#import "RWTImgurImageViewController.h"
#import "RWTProgressNavigationController.h"


@interface RWTHotGalleryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSArray *images;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation RWTHotGalleryViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  RWTProgressNavigationController *navigationController = (RWTProgressNavigationController *)self.navigationController;
  self.progressView = navigationController.progressView;
  self.progressView.hidden = YES;
  
  __weak RWTHotGalleryViewController *weakSelf = self;
  [[RWTImgurService sharedInstance] hotViralGalleryThumbnailImagesPage:0 completion:^(NSArray *images, NSError *error) {
    if (!error) {
      weakSelf.images = images;
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.imagesCollectionView reloadData];
      });
      
    } else {
      NSLog(@"Error fetching hot images: %@", error);
    }
  }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ViewImage"]) {
    RWTImgurImageViewController *imageViewController = segue.destinationViewController;
    RWTImageCollectionViewCell *cell = sender;
    NSIndexPath *indexPath = [self.imagesCollectionView indexPathForCell:cell];
    imageViewController.imgurImage = self.images[indexPath.row];
  }
}

- (IBAction)share:(id)sender {
  UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
  pickerController.delegate = self;
  pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
  [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
  [self dismissViewControllerAnimated:YES completion:nil];
  
  [[RWTImgurService sharedInstance] uploadImage:selectedImage title:@"ObjC" completion:^(RWTImgurImage *image, NSError *error)
  {
    if (error == nil) {
      NSString *message = [NSString stringWithFormat:@"URL: %@", image.link.absoluteString];
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Upload Finished"
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:image.link];
      }];
      
      UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [UIPasteboard generalPasteboard].URL = image.link;
      }];
      
      [alert addAction:openAction];
      [alert addAction:copyAction];
      [self presentViewController:alert animated:YES completion:nil];
      
      self.progressView.hidden = YES;
      [self.progressView setProgress:0 animated:NO];
      
    } else {
      NSLog(@"Upload error: %@", error);
      self.progressView.hidden = YES;
    }
    
  } progressCallback:^(float progress)
  {
    if (progress > 0) {
      self.progressView.hidden = NO;
      [self.progressView setProgress:progress animated:YES];
    }
  }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  RWTImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
  
  cell.imgurImage = self.images[indexPath.row];
  
  return cell;
}

@end
