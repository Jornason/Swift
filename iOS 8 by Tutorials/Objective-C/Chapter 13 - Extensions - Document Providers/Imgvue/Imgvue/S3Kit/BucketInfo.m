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

#import "BucketInfo.h"
#import "S3Image.h"

@import UIKit;
@import MobileCoreServices;
#import <AWSS3/AWSS3.h>
#import <AWSRuntime/AWSRuntime.h>


NSString* const ACCESS_KEY_ID = @"<#Access Key ID#>";
NSString* const SECRET_KEY = @"<#Secret Key#>";
NSString* const BUCKET_NAME = @"<#Bucket Name#>";

@interface BucketInfo ()
@property (strong, nonatomic) NSMutableArray* files;
@property (strong, nonatomic) AmazonS3Client* s3;
@end

@implementation BucketInfo

- (instancetype)init {
  self = [super init];
  if (self) {
    _files = [NSMutableArray array];
    _s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    _s3.endpoint = [AmazonEndpoints s3Endpoint:US_EAST_1];
    
  }
  return self;
}

- (NSData*) getObject:(NSString*)key bucket:(NSString*)bucketName {
  S3GetObjectRequest* request = [[S3GetObjectRequest alloc] initWithKey:key withBucket:bucketName];
  S3GetObjectResponse* response = [self.s3 getObject:request];
  return response.body;
}

- (NSData*) load:(NSString*)imageKey {
  return [self getObject:imageKey bucket:BUCKET_NAME];
}

- (NSArray*) listObjects:(NSString*)bucket {
  S3ListObjectsRequest* lor = [[S3ListObjectsRequest alloc] initWithName:bucket];
  S3ListObjectsResponse* resp = [self.s3 listObjects:lor];
  S3ListObjectsResult* res = resp.listObjectsResult;
  return res.objectSummaries;
}

- (void) load:(void(^)())initalLoadBlock thumbnailBlock:(void(^)(NSIndexPath* indexPath)) thumbnailBlock {

  NSArray* summaries = [self listObjects:BUCKET_NAME];

  NSArray* fileArray = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];

  NSMutableArray* images = [NSMutableArray array];
  for (S3ObjectSummary* summary in summaries) {
    S3Image* imWrapper = [[S3Image alloc] initWithSummary:summary];
    [images addObject:imWrapper];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSData* data = [self getObject:summary.key bucket:BUCKET_NAME];
      if (data) {
        NSURL* url = [(NSURL*)fileArray[0] URLByAppendingPathComponent:summary.key];
        [data writeToURL:url atomically:YES];
        imWrapper.url = url;

        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[images indexOfObject:imWrapper] inSection:0];
        thumbnailBlock(indexPath);
      }
    });
  }

  self.files = images;
  initalLoadBlock();
}

- (NSUInteger) fileCount {
  return self.files.count;
}

- (S3Image*) objAtIndex:(NSIndexPath*)indexPath {
  return self.files[indexPath.row];
}

- (NSError*) putJPEG:(NSData*)imageData key:(NSString*)imageName bucket:(NSString*)bucketName
{
  S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:imageName inBucket:bucketName];
  putObjectRequest.contentType = (id) kUTTypeJPEG;
  putObjectRequest.data = imageData;
  
  S3PutObjectResponse* putObjectResponse = [self.s3 putObject:putObjectRequest];
  NSError* error = putObjectResponse.error;
  
  return error;
}

- (void) uploadImage:(UIImage*)image name:(NSString*)name completion:(void(^)(S3Image* imageObj, NSError* error))completion {
  NSData* imageData = UIImageJPEGRepresentation(image, 0.9);
  NSError* error = [self putJPEG:imageData key:name bucket:BUCKET_NAME];
  
  S3Image* imageObj = nil;
  if (!error) {
    imageObj = [[S3Image alloc] init];
    
    NSArray* fileArray = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL* url = [fileArray[0] URLByAppendingPathComponent:name];
    imageObj.url = url;
  }
  completion(imageObj, error);
}

- (void) uploadData:(NSData*)data name:(NSString*)name completion:(void(^)(NSError* error))completion {
  completion([self putJPEG:data key:name bucket:BUCKET_NAME]);
}

@end

