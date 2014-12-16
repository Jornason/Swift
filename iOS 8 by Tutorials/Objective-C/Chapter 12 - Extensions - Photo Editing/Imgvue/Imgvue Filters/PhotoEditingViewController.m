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

#import "PhotoEditingViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "RWTImageFilterService.h"

@interface PhotoEditingViewController () <PHContentEditingController>

@property (strong) PHContentEditingInput *input;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *addFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;

@property (strong, nonatomic) RWTImageFilterService *imageFilterService;
@property (strong, nonatomic) NSString *currentFilterName;
@property (strong, nonatomic) UIImage *filteredImage;

@end

@implementation PhotoEditingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.imageFilterService = [[RWTImageFilterService alloc] init];
}

- (IBAction)undo:(id)sender {
  self.imageView.image = self.input.displaySizeImage;
  self.currentFilterName = nil;
  self.filteredImage = nil;
}

- (IBAction)addFilter:(UIButton *)sender {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Filter" message:@"Choose a filter to apply to the image" preferredStyle:UIAlertControllerStyleActionSheet];
  
  [self.imageFilterService.availableFilters enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *filter, BOOL *stop) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      self.filteredImage = [self.imageFilterService applyFilter:filter toImage:self.input.displaySizeImage];
      self.imageView.image = self.filteredImage;
      self.currentFilterName = filter;
    }];
    [alert addAction:action];
  }];
  
  UIAlertAction *noneAction = [UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    [self undo:nil];
  }];
  
  [alert addAction:noneAction];
  [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
  // Inspect the adjustmentData to determine whether your extension can work with past edits.
  // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
  return NO;
}
- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
  // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
  // If you returned YES from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
  // If you returned NO, the contentEditingInput has past edits "baked in".
  self.input = contentEditingInput;
  
  self.imageView.image = self.input.displaySizeImage;
  
}
- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler {
  // Update UI to reflect that editing has finished and output is being rendered.
  
  if (self.currentFilterName == nil || self.input == nil) {
    [self cancelContentEditing];
    return;
  }
  
  // Render and provide output on a background queue.
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // Create editing output from the editing input.
    PHContentEditingOutput *output = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.input];
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.currentFilterName];
    PHAdjustmentData *adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:@"com.raywenderlich.imgvue-imgvue-filters" formatVersion:@"1.0" data:archiveData];
    output.adjustmentData = adjustmentData;
    
    UIImage *fullImage = [UIImage imageWithContentsOfFile:self.input.fullSizeImageURL.path];
    fullImage = [self.imageFilterService applyFilter:self.currentFilterName toImage:fullImage];
    
    NSData *jpegData = UIImageJPEGRepresentation(fullImage, 1.0);
    NSError *saveError;
    BOOL saved = [jpegData writeToURL:output.renderedContentURL options:NSDataWritingAtomic error:&saveError];
    if (saved) {
      completionHandler(output);
    } else {
      NSLog(@"An error occurred during save: %@", saveError);
      completionHandler(nil);
    }
  });
}
- (BOOL)shouldShowCancelConfirmation {
  // Returns whether a confirmation to discard changes should be shown to the user on cancel.
  // (Typically, you should return YES if there are any unsaved changes.)
  return NO;
}
- (void)cancelContentEditing {
  // Clean up temporary files, etc.
  // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
}

@end

