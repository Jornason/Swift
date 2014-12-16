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
@import CloudKit;

#import "Model.h"

NSString * const RatingRecordType = @"Rating";
NSString * const EstablishmentRecordType = @"Establishment";
NSString * const NotesRecordType = @"Note";


@interface Model ()
@property (strong, nonatomic) CKContainer* container;
@property (strong, nonatomic) CKDatabase* privateDb;

@end

@implementation Model

+ (instancetype)model
{
  static Model* model;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    model = [[self alloc] init];
  });
  return model;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _items = [NSMutableArray array];
    
    _container = [CKContainer defaultContainer];
    _db = [_container publicCloudDatabase];
    _privateDb = [_container privateCloudDatabase];
    
    _user = [[UserInfo alloc] initWithContainer:_container];
  }
  return self;
}

- (Establishment *)establishmentWithID:(CKRecordID*)establishmentID
{
  NSArray* a = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"record.recordID == %@", establishmentID]];
  Establishment* e = nil;
  if (a && a.count > 0) {
    e = a[0];
  }
  return e;
}

- (Establishment*) establishmentForRef:(CKReference*)ref
{
  return [self establishmentWithID:ref.recordID];
}

- (NSPredicate*) createLocationPredicate:(CLLocation*)location radiusInMeters:(CLLocationDistance)radiusInMeters {
  CLLocationDistance radiusInKilometers = radiusInMeters / 1000.0;
  return [NSPredicate predicateWithFormat:@"distanceToLocation:fromLocation:(%K,%@) < %f", @"Location", location, radiusInKilometers];
}

- (void)refresh {
  NSPredicate* predicate = [NSPredicate predicateWithValue:YES];
  CKQuery* query = [[CKQuery alloc] initWithRecordType:EstablishmentRecordType predicate:predicate];
  [_db performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
    if (!error) {
      [_items removeAllObjects];
      for (CKRecord* qrecord in results) {
        id obj = [[Establishment alloc] initWithRecord:qrecord database:self.db];
        if (obj) {
          [_items addObject:obj];
        }
      }
      
      if (self.delegate && [self.delegate respondsToSelector:@selector(modelUpdated)]) {
        [self.delegate modelUpdated];
      }
      
    } else {
      if (self.delegate && [self.delegate respondsToSelector:@selector(errorUpdatingModel:)]) {
        [self.delegate errorUpdatingModel:error];
      }
    }
  }];
}

- (void) addPhoto:(NSURL*)localURL to:(Establishment*)e
{
  CKAsset* a = [[CKAsset alloc] initWithFileURL:localURL];
  if (a) {
    CKRecord* record = e.record;
    NSArray* photos = record[@"Photos"];
    if (!photos) {
      photos = @[a];
    } else {
      photos = [photos arrayByAddingObject:a];
    }
    record[@"Photos"] = photos;
    [_db saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
      if (!error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelUpdatedAtIndexPath:)]) {
          NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.items indexOfObject:e] inSection:0];
          dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate modelUpdatedAtIndexPath:indexPath];
          });
        }
        
      } else {
        //handle error
      }
    }];
  }
}


- (NearbyLocationsResultsController*) makeController:(id<NearbyLocationsResultsControllerDelegate>)delegate {
  return [[NearbyLocationsResultsController alloc] initWithDatabase:self.db delegate:delegate];
}


- (void) refreshEstablishmentsNear:(CLLocation*)location within:(CGFloat)radiusInKilometers
{
  [self establishmentsNear:location within:radiusInKilometers completion:^(NSArray *array, NSError* error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (error) {
        if ([self.delegate respondsToSelector:@selector(errorUpdatingModel:)]) {
          [self.delegate errorUpdatingModel:error];
        }
      } else {
        if ([self.delegate respondsToSelector:@selector(modelUpdated)]) {
          [self.delegate modelUpdated];
        }
      }
    });
  }];
}

- (void) establishmentsNear:(CLLocation*)location within:(CGFloat)radiusInKilometers completion:(void(^)(NSArray* array, NSError* error))completion
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"distanceToLocation:fromLocation:(Location, %@) < %f", location, radiusInKilometers];
  
  CKQuery *query = [[CKQuery alloc] initWithRecordType:EstablishmentRecordType predicate:predicate];
  [_db performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
    NSMutableArray* establishments = [NSMutableArray array];
    for (CKRecord* record in results) {
      Establishment* e = [[Establishment alloc] initWithRecord:record database:self.db];
      if (e) {
        [establishments addObject:e];
      }
    }
    completion(establishments, error);
  }];
}

#pragma mark - Notes
- (void)addNote:(NSString *)note to:(Establishment *)e completion:(void(^)(NSError* error))completion
{
  if (!e) {
    return;
  }
  
  CKRecord* noteRecord = [[CKRecord alloc] initWithRecordType:@"Note"];
  noteRecord[@"Note"] = note;
  CKReference* ref = [[CKReference alloc] initWithRecord:e.record action:CKReferenceActionDeleteSelf];
  noteRecord[@"Establishment"] = ref;
  
  [self.privateDb saveRecord:noteRecord completionHandler:^(CKRecord *record, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(error);
    });
  }];
}

- (void) fetchNotes:(void(^)(NSArray* notes, NSError* error))completion
{
  NSPredicate* predicate = [NSPredicate predicateWithValue:YES];
  CKQuery *query = [[CKQuery alloc] initWithRecordType:NotesRecordType predicate:predicate];
  [self.privateDb performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
    NSMutableArray* a = [NSMutableArray arrayWithCapacity:results.count];
    if (!error) {
      for (CKRecord* noteRecord in results) {
        NSMutableDictionary* noteValue = [NSMutableDictionary dictionary];
        NSString* note = noteRecord[@"Note"];
        if (note) {
          noteValue[@"Note"] = note;
        }
        CKReference* establishmentRef = noteRecord[@"Establishment"];
        if (establishmentRef) {
          CKRecordID* recordId = establishmentRef.recordID;
          if (recordId) {
            Establishment* e = [self establishmentWithID:recordId];
            if (e) {
              noteValue[@"Establishment"] = e;
            }
          }
        }
        [a addObject:noteValue];
      }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(a, error);
    });
  }];
}


@end
