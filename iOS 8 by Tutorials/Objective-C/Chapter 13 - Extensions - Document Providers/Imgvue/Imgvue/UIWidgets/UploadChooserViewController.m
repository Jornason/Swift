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

#import "UploadChooserViewController.h"

@import MobileCoreServices;
@import S3Kit;

@interface UploadChooserViewController () <UIDocumentMenuDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation UploadChooserViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self resetUIState];
}

- (void) resetUIState {
  [self.uploadProgressView setProgress:0.0];
  [self.uploadProgressView setHidden:YES];
}

- (IBAction)selectImageToUpload:(UIControl*)sender {

  NSArray* types = @[(id)kUTTypeImage];
  UIDocumentMenuViewController* docMenu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
  docMenu.delegate = self;
  docMenu.modalPresentationStyle = UIModalPresentationPopover;

  [docMenu addOptionWithTitle:@"Saved Photo" image:nil order:UIDocumentMenuOrderFirst handler:^{
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imagePicker animated:YES completion:nil];
  }];
  
  UIPopoverPresentationController* presentationControler = docMenu.popoverPresentationController;
  if (presentationControler) {
    presentationControler.sourceView = self.view;
    presentationControler.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationControler.sourceRect = sender.frame;
  }
  
  [self presentViewController:docMenu animated:YES completion:nil];
}

#pragma mark - Doc Menu Delegate

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker {
  documentPicker.delegate = self;
  [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - Doc Picker Delegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
  NSFileCoordinator* coordinator = [[NSFileCoordinator alloc] init];
  [coordinator coordinateReadingItemAtURL:url
                                  options:NSFileCoordinatorReadingForUploading
                                    error:nil byAccessor:^(NSURL *newURL) {
                                      NSData* fileData = [NSData dataWithContentsOfURL:newURL];
                                      BucketInfo* bucketInfo = [[BucketInfo alloc] init];
                                      NSString* filename = [newURL lastPathComponent];
                                      [bucketInfo uploadData:fileData name:filename completion:^(NSError *error) {
                                        if (error) {
                                          NSLog(@"error uploading: %@", error);
                                        }
                                      }];
                                    }];
}

#pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [self dismissViewControllerAnimated:YES completion:nil];
  UIImage* selectedImage = info[UIImagePickerControllerOriginalImage];
  if (selectedImage) {
    BucketInfo* bucketInfo = [[BucketInfo alloc] init];
    NSString* name = [NSUUID UUID].UUIDString;
    [bucketInfo uploadImage:selectedImage name:name completion:^(S3Image *imageObj, NSError *error) {
      if (error) {
        NSLog(@"error uploading: %@", error);
      }
    }];
  }
}

@end
