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


#import "ViewController.h"

@import MobileCoreServices;

@interface ViewController () <UIDocumentPickerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSURL* lastURL;
@end

@implementation ViewController

- (IBAction)open:(id)sender {
  
  UIDocumentPickerViewController *vc = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeImage] inMode:UIDocumentPickerModeOpen];
  vc.delegate = self;
  [self presentViewController:vc animated:YES completion:^{}];
}

- (IBAction)import:(id)sender {
  UIDocumentPickerViewController *vc = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeImage] inMode:UIDocumentPickerModeImport];
  vc.delegate = self;
  [self presentViewController:vc animated:YES completion:^{}];
}

- (IBAction)move:(id)sender {
  [self downloadImage:^(NSURL *url) {
    UIDocumentPickerViewController* vc = [[UIDocumentPickerViewController alloc] initWithURL:url inMode:UIDocumentPickerModeMoveToService];
    vc.delegate = self;
    UIImage* im = [UIImage imageWithContentsOfFile:url.path];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.imageView.image = im;
      [self presentViewController:vc animated:YES completion:^{}];
    });
  }];
  
}

- (void) downloadImage:(void(^)(NSURL* url))completion
{
  NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  [[session downloadTaskWithURL:[NSURL URLWithString:@"http://thecatapi.com/api/images/get?format=src&type=jpg"] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
    NSURL* outurl = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    outurl = [outurl URLByAppendingPathComponent:@"temp.jpg"];
    NSData* d = [NSData dataWithContentsOfFile:location.path];
    [d writeToURL:outurl atomically:YES];
    if (!error) {
      completion(outurl);
    }
  }] resume];
}

- (IBAction)export:(id)sender {
  [self downloadImage:^(NSURL *url) {
    UIDocumentPickerViewController* vc = [[UIDocumentPickerViewController alloc] initWithURL:url inMode:UIDocumentPickerModeExportToService];
    vc.delegate = self;
    UIImage* im = [UIImage imageWithContentsOfFile:url.path];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.imageView.image = im;
      [self presentViewController:vc animated:YES completion:^{}];
    });
  }];
}

- (void) loadImage:(NSURL*)url {
  NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
  [fileCoordinator coordinateReadingItemAtURL:url
                                      options:NSFileCoordinatorReadingWithoutChanges
                                        error:nil
                                   byAccessor:^(NSURL *newURL) {
                                     
     NSData *data = [NSData dataWithContentsOfURL:newURL];
     UIImage* image = [UIImage imageWithData:data];
     self.imageView.image = image;
  }];
}

- (void) importImage:(NSURL*)url
{
  NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
  [fileCoordinator coordinateReadingItemAtURL:url
                                      options:NSFileCoordinatorReadingWithoutChanges
                                        error:nil
                                   byAccessor:^(NSURL *newURL) {
                                     
     NSData *data = [NSData dataWithContentsOfURL:newURL];
     UIImage* image = [UIImage imageWithData:data];
     self.imageView.image = image;
  }];
}

- (void) openImage:(NSURL*)url
{
  BOOL accessing = [url startAccessingSecurityScopedResource];
  if (accessing) {
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    [fileCoordinator coordinateReadingItemAtURL:url
                                        options:NSFileCoordinatorReadingWithoutChanges
                                          error:nil
                                     byAccessor:^(NSURL *newURL) {
                                       
       NSData *data = [NSData dataWithContentsOfURL:newURL];
       UIImage* image = [UIImage imageWithData:data];
       self.imageView.image = image;
    }];
  }
  [url stopAccessingSecurityScopedResource];
}

- (void) writeImage:(NSURL*)url {
  UIImage* im = self.imageView.image;
  
   NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
   NSError* error = nil;
   [fileCoordinator coordinateWritingItemAtURL:url options:NSFileCoordinatorWritingForReplacing error:&error byAccessor:^(NSURL *newURL) {
     NSData* d = UIImageJPEGRepresentation(im, 0.9);
     [d writeToURL:newURL atomically:YES];
   }];
   NSLog(@"write error: %@", error);
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
  didPickDocumentAtURL:(NSURL *)url {
  
  [self dismissViewControllerAnimated:YES completion:nil];
  self.lastURL = url;
  if (controller.documentPickerMode == UIDocumentPickerModeImport) {
    [self importImage:url];
  } else if (controller.documentPickerMode == UIDocumentPickerModeOpen) {
    [self openImage:url];
  } else {
    [self writeImage:nil];
  }
  
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
  if (controller.documentPickerMode == UIDocumentPickerModeOpen || controller.documentPickerMode == UIDocumentPickerModeImport) {
    self.imageView.image = nil;
  }
}

#pragma mark -

- (UIImage*) addGreenSquareToImage:(UIImage*)image {
  
  CGRect imRect = CGRectMake(0, 0, image.size.width, image.size.height);

  CGFloat halfWidth = image.size.width / 2;
  CGFloat x = arc4random_uniform(halfWidth);
  CGFloat halfHeight = image.size.height / 2;
  CGFloat y = arc4random_uniform(halfHeight);
  CGRect squareRect = CGRectMake(x, y, halfWidth, halfHeight);
  
  UIGraphicsBeginImageContext(image.size);
  [image drawInRect:imRect];

  UIBezierPath* square = [UIBezierPath bezierPathWithRect:squareRect];
  [[[UIColor greenColor] colorWithAlphaComponent:0.5] setFill];
  [square fill];

  UIImage* newIm = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  self.imageView.image = newIm;
  return newIm;
}

- (IBAction)modify:(id)sender {
  UIImage* image = self.imageView.image;
  if (image) {
    UIImage* newIm = [self addGreenSquareToImage:image];
    if (self.lastURL) {
      NSData* data =  UIImageJPEGRepresentation(newIm, 0.9);
      
      NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] init];
      NSError* error = nil;
      [fileCoordinator coordinateWritingItemAtURL:self.lastURL
                                          options:NSFileCoordinatorWritingForReplacing
                                            error:&error
                                       byAccessor:^(NSURL *newURL) {
                                         [data writeToURL:newURL atomically:YES];
                                       }];
      if (error) {
        NSLog(@"error writing file: %@", error);
      }
    }
  }
}


@end
