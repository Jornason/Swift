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

#import "Establishment.h"
#import "UserInfo.h"
#import "Model.h"

@import UIKit;

@interface Establishment () 
@end

@implementation Establishment

- (instancetype) initWithRecord:(CKRecord *)record database:(CKDatabase*)database {
  self = [super init];
  if (self) {
    _record = record;
    _database = database;
    
    _name = record[@"Name"];
    _location = record[@"Location"];
  }
  return self;
}

- (void) fetchRating:(void(^)(double rating, BOOL isUser))completion {
  [[Model model].user userID:^(CKRecordID *recordID, NSError *error) {
    [self fetchRating:recordID completion:completion];
  }];
}

- (void) fetchRating:(CKRecordID*)userRecord completion:(void(^)(double rating, BOOL isUser))completion {

  NSPredicate* predicate = [NSPredicate predicateWithFormat:@"Establishment == %@", self.record];
  CKQuery* query = [[CKQuery alloc] initWithRecordType:@"Rating" predicate:predicate];
  [self.database performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
    if (error) {
      completion(0, false);
      NSLog(@"error loading rating: %@", error);
    } else {
      double rating = [[results valueForKeyPath:@"@avg.Rating"] doubleValue];
      completion(rating, false);
    }
  }];
  
}

- (BOOL)hasHealthyOptions
{
    return [self.record[@"HealthyOption"] boolValue];
}

- (BOOL)hasKidsMenu
{
    return [self.record[@"KidsMenu"] boolValue];
}

- (ChangingTableType)changingTableType
{
    return [self.record[@"ChangingTable"] integerValue];
}

- (void) loadCoverPhoto:(void(^)(UIImage* photo))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    UIImage* image = nil;
    
    CKAsset* coverPhoto = self.record[@"CoverPhoto"];
    if (coverPhoto) {
      NSURL* url = coverPhoto.fileURL;
      if (url) {
        NSData* imageData = [NSData dataWithContentsOfFile:url.path];
        image = [UIImage imageWithData:imageData];
      }
    }
    completion(image);
  });
}

- (void) fetchNote:(void(^)(NSString* note))completion {
  [[Model model] fetchNotes:^(NSArray *notes, NSError *error) {
    NSDictionary* note = [notes count] > 0 ? notes[0] : nil;
    completion(note[@"Note"]);
  }];
}

- (void) fetchPhotos:(void(^)(NSArray* assets))completion {
  NSPredicate* predicate = [NSPredicate predicateWithFormat:@"Establishment == %@", self.record];
  CKQuery* query = [[CKQuery alloc] initWithRecordType:@"EstablishmentPhoto" predicate:predicate];
  [self.database performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
    if (error == nil) {
      _assetCount = results.count;
    }
    completion(results);
  }];
}

#pragma mark - Annotation

- (NSString *)title
{
    return self.name;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocation* loc = self.record[@"Location"];
    return [loc coordinate];
}

@end
