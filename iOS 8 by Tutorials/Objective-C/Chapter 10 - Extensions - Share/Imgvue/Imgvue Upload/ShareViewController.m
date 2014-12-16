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

#import "ShareViewController.h"
#import "RWTImgurService.h"
#import "RWTImgurImage.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()

@property (strong, nonatomic) UIImage *imageToShare;

@end

@implementation ShareViewController

- (void)viewDidLoad {

#warning SET YOUR CLIENT ID
  [RWTImgurService setClientId:@"YOUR_CLIENT_ID"];

  
  NSExtensionItem *firstItem = self.extensionContext.inputItems.firstObject;
  NSItemProvider *itemProvider;
  if (firstItem != nil) {
    itemProvider = firstItem.attachments.firstObject;
  }
  
  if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
    [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error)
    {
      if (error == nil) {
        NSURL *url = (NSURL *)item;
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        self.imageToShare = [UIImage imageWithData:imageData];
      } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to load image" message:@"Please try again or choose a different image." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *bummerAction = [UIAlertAction actionWithTitle:@"Bummer" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
          [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:bummerAction];
        [self presentViewController:alert animated:YES completion:nil];
      }
    }];
  }
}


- (void)shareImage {
  
  NSURLSession *defaultSession = [RWTImgurService sharedInstance].session;
  NSURLSessionConfiguration *defaultConfig = defaultSession.configuration;
  NSDictionary *defaultHeaders = defaultConfig.HTTPAdditionalHeaders;
  
  NSURLSessionConfiguration *backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.raywenderlich.imgvue.backgroundsession"];
  backgroundConfig.sharedContainerIdentifier = @"group.com.raywenderlich.imgvue";
  backgroundConfig.HTTPAdditionalHeaders = defaultHeaders;
  
  NSURLSession *backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfig delegate:[RWTImgurService sharedInstance] delegateQueue:[NSOperationQueue mainQueue]];
  
  
  [[RWTImgurService sharedInstance] uploadImage:self.imageToShare session:backgroundSession title:self.contentText completion:^(RWTImgurImage *image, NSError *error)
  {
    if (error == nil) {
      [UIPasteboard generalPasteboard].URL = image.link;
      NSLog(@"Image shared: %@", image.link.absoluteString);
    } else {
      NSLog(@"Error sharing image: %@", error);
    }
  } progressCallback:^(float progress) {
    NSLog(@"Upload progress for extension: %f", progress);
  }];
  
  
  [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (BOOL)isContentValid {
  if (self.imageToShare != nil) {
    return YES;
  } else {
    return NO;
  }
}

- (void)didSelectPost {
  [self shareImage];
}

- (NSArray *)configurationItems {
  SLComposeSheetConfigurationItem *configItem = [[SLComposeSheetConfigurationItem alloc] init];
  configItem.title = @"URL will be copied to clipboard";
  return @[configItem];
}

@end
