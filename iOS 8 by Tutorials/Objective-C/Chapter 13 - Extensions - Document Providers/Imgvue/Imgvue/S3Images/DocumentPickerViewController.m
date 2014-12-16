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

@import UIKit;
@import UIWidgets;
@import S3Kit;

#import "DocumentPickerViewController.h"
#import "UploadViewController.h"

@interface DocumentPickerViewController () <ThumbnailDelegate, NSFileManagerDelegate>

@end

@implementation DocumentPickerViewController

- (void)didSelectImage:(S3Image *)image {
  NSURL* imageUrl = image.url;
  NSString* filename = [imageUrl.pathComponents lastObject];
  NSURL* outUrl = [self.documentStorageURL URLByAppendingPathComponent:filename];
  
  NSFileCoordinator* coordinator = [[NSFileCoordinator alloc] init];
  [coordinator coordinateWritingItemAtURL:outUrl
                                  options:NSFileCoordinatorWritingForReplacing
                                    error:nil
                               byAccessor:^(NSURL *newURL) {
                                 NSFileManager* fm = [[NSFileManager alloc] init];
                                 fm.delegate = self;
                                 [fm copyItemAtURL:imageUrl toURL:outUrl error:nil];
                               }];

  [self dismissGrantingAccessToURL:outUrl];
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL {
  return YES;
}

- (void)prepareForPresentationInMode:(UIDocumentPickerMode)mode {
  UINavigationController* nav = self.childViewControllers[0];
  ThumbnailCollectionViewController* thumbController = (ThumbnailCollectionViewController*) [nav topViewController];
  
  [thumbController.navigationController setNavigationBarHidden:YES animated:NO];
  
  if (mode == UIDocumentPickerModeExportToService || mode == UIDocumentPickerModeMoveToService) {
    [thumbController performSegueWithIdentifier:@"upload" sender:nil];
  } else {
    thumbController.delegate = self;
  }
}

- (void)nameChosen:(NSString *)name {
  NSString* justFilename = [name stringByDeletingPathExtension];
  NSURL* exportURL = [[self.documentStorageURL URLByAppendingPathComponent:justFilename] URLByAppendingPathExtension:@"jpg"];
  [self upload:name url:exportURL];
}

- (void) upload:(NSString*)name url:(NSURL*)outURL {
  BOOL access = [self.originalURL startAccessingSecurityScopedResource];
  if (access) {
    NSFileCoordinator* fc = [[NSFileCoordinator alloc] init];
    NSError* error = nil;
    [fc coordinateReadingItemAtURL:self.originalURL
                           options:NSFileCoordinatorReadingForUploading
                             error:&error byAccessor:^(NSURL *newURL) {
                               BucketInfo* bucket = [[BucketInfo alloc] init];
                               NSData* data = [NSData dataWithContentsOfURL:newURL];
                               [bucket uploadData:data name:name completion:^(NSError *error) {
                                 if (error) {
                                   NSLog(@"error uploading %@", error);
                                 }
                               }];
                               [data writeToURL:outURL atomically:YES];
                               [self dismissGrantingAccessToURL:outURL];
                             }];
    [self.originalURL stopAccessingSecurityScopedResource];
  }
}


@end
