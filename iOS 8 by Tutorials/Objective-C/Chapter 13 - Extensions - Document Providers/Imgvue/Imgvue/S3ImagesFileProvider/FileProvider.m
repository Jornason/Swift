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


#import "FileProvider.h"
@import UIKit;
@import S3Kit;

@interface FileProvider ()

@end

@implementation FileProvider

- (NSFileCoordinator *)fileCoordinator {
  NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
  [fileCoordinator setPurposeIdentifier:[self providerIdentifier]];
  return fileCoordinator;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self.fileCoordinator coordinateWritingItemAtURL:[self documentStorageURL] options:0 error:nil byAccessor:^(NSURL *newURL) {
      // ensure the documentStorageURL actually exists
      NSError *error = nil;
      [[NSFileManager defaultManager] createDirectoryAtURL:newURL withIntermediateDirectories:YES attributes:nil error:&error];
    }];
  }
  return self;
}

- (void)providePlaceholderAtURL:(NSURL *)url completionHandler:(void (^)(NSError *error))completionHandler {
  // Should call + writePlaceholderAtURL:withMetadata:error: with the placeholder URL, then call the completion handler with the error if applicable.
  NSString* fileName = [url lastPathComponent];
  
  NSURL *placeholderURL = [NSFileProviderExtension placeholderURLForURL:[self.documentStorageURL URLByAppendingPathComponent:fileName]];
  
  NSUInteger fileSize = 0;
  // TODO: get file size for file at <url> from model
  
  [self.fileCoordinator coordinateWritingItemAtURL:placeholderURL options:0 error:NULL byAccessor:^(NSURL *newURL) {
    
    NSDictionary* metadata = @{ NSURLFileSizeKey : @(fileSize)};
    [NSFileProviderExtension writePlaceholderAtURL:placeholderURL withMetadata:metadata error:NULL];
  }];
  if (completionHandler) {
    completionHandler(nil);
  }
}

- (void)startProvidingItemAtURL:(NSURL *)url completionHandler:(void (^)(NSError *))completionHandler {
  NSFileManager* fileManager = [[NSFileManager alloc] init];
  NSString* path = url.path;
  
  if ([fileManager fileExistsAtPath:path]) {
    completionHandler(nil);
    return;
  }
  
  //load the file data from Amazon S3
  NSString* key = url.lastPathComponent;
  BucketInfo* bucket = [[BucketInfo alloc] init];
  NSData* fileData = [bucket load:key];
  
  NSError* error = nil;
  [[self fileCoordinator] coordinateWritingItemAtURL:url
                                             options:NSFileCoordinatorWritingForReplacing
                                               error:&error byAccessor:^(NSURL *newURL) {
                                                 [fileData writeToURL:newURL atomically:YES];
                                               }];
  completionHandler(error);
}


- (void)itemChangedAtURL:(NSURL *)url {
  // Called at some point after the file has changed; the provider may then trigger an upload
  
  NSLog(@"Item changed at URL %@", url);

  NSString* key = url.lastPathComponent;
  BucketInfo* bucket = [[BucketInfo alloc] init];

  [[self fileCoordinator] coordinateReadingItemAtURL:url options:NSFileCoordinatorReadingForUploading error:nil byAccessor:^(NSURL *newURL) {
    NSData* data = [NSData dataWithContentsOfURL:newURL];
    [bucket uploadData:data name:key completion:^(NSError *error) {
      if (error) {
        NSLog(@"error uploading updated file: %@", error);
      }
    }];
  }];
}

- (void)stopProvidingItemAtURL:(NSURL *)url {
  // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
  // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.
  
  [self.fileCoordinator coordinateWritingItemAtURL:url options:NSFileCoordinatorWritingForDeleting error:NULL byAccessor:^(NSURL *newURL) {
    [[NSFileManager defaultManager] removeItemAtURL:newURL error:NULL];
  }];
  [self providePlaceholderAtURL:url completionHandler:NULL];
}

@end
