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

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  
  if (self) {
    NSString* recordName = [aDecoder decodeObjectForKey:@"recordName"];
    CKRecordID* recordID = [[CKRecordID alloc] initWithRecordName:recordName];
    _record = [[CKRecord alloc] initWithRecordType:@"Establishment" recordID:recordID];
    _database = [Model model].db;
    
    
    _record[@"KidsMenu"] = @([aDecoder decodeBoolForKey:@"KidsMenu"]);
    _record[@"HealthyOption"] = @([aDecoder decodeBoolForKey:@"HealthyOption"]);
    
    CLLocationDegrees lat = [aDecoder decodeDoubleForKey:@"latitude"];
    CLLocationDegrees lon = [aDecoder decodeDoubleForKey:@"longitude"];
    _location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    _record[@"Location"] = _location;
    
    _name = [aDecoder decodeObjectForKey:@"Name"];
    _record[@"Name"] = _name;
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.record.recordID.recordName forKey:@"recordName"];
  [aCoder encodeBool:self.hasKidsMenu forKey:@"KidsMenu"];
  [aCoder encodeBool:self.hasHealthyOptions forKey:@"HealthyOption"];

  [aCoder encodeDouble:self.location.coordinate.latitude forKey:@"latitude"];
  [aCoder encodeDouble:self.location.coordinate.longitude forKey:@"longitude"];

  [aCoder encodeObject:self.name forKey:@"Name"];
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

NSString* imageCachePath(CKRecord* record) {
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  return [paths[0] stringByAppendingPathComponent:record.recordID.recordName];
}

- (void) loadCoverPhoto:(void(^)(UIImage* photo))completion {
  dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSString* imagePath = imageCachePath(self.record);
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
      UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(image);
      });
    } else {
      CKFetchRecordsOperation* fetchOp = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[self.record.recordID]];
      fetchOp.desiredKeys = @[@"CoverPhoto"];
      [fetchOp setFetchRecordsCompletionBlock:^(NSDictionary *records, NSError *error) {
        [self processAsset:records error:error completion:completion];
      }];
      [self.database addOperation:fetchOp];
    }
  });
}


  
- (void) processAsset:(NSDictionary*)records error:(NSError*)error completion:(void(^)(UIImage* photo))completion {
  if (error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(nil);
    });
    return;
  }
  
  CKRecord* updatedRecord = records[self.record.recordID];
  CKAsset* asset = updatedRecord[@"CoverPhoto"];
  if (asset) {
    NSURL* url = asset.fileURL;
    UIImage* im = [UIImage imageWithContentsOfFile:url.path];
    [[NSFileManager defaultManager] copyItemAtPath:url.path toPath:imageCachePath(self.record) error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(im);
    });
  } else {
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(nil);
    });
  }
}

- (void) fetchNote:(void(^)(NSString* note))completion {
  [[Model model] fetchNotes:^(NSArray *notes, NSError *error) {
    NSString* note = [notes count] > 0 ? notes[0] : nil;
    completion(note);
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
