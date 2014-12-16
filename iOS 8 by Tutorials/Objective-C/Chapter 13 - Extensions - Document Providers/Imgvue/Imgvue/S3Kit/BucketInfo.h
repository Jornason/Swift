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

@import Foundation;
@import UIKit;

@class S3Image;

@interface BucketInfo : NSObject
- (NSData*) load:(NSString*)imageKey;

- (void) load:(void(^)())initalLoadBlock thumbnailBlock:(void(^)(NSIndexPath* indexPath)) thumbnailBlock;
- (NSUInteger) fileCount;
- (S3Image*) objAtIndex:(NSIndexPath*)indexPath;

- (void) uploadImage:(UIImage*)image name:(NSString*)name completion:(void(^)(S3Image* imageObj, NSError* error))completion;
- (void) uploadData:(NSData*)data name:(NSString*)name completion:(void(^)(NSError* error))completion;
@end
