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

#import "Workaround.h"
#import "Establishment.h"
#import "Model.h"

@import CloudKit;
@import CoreLocation;

@implementation Workaround

void upload(CKDatabase* db,
            NSString* imageName,
            NSString* placeName,
            CLLocationDegrees latitude,
            CLLocationDegrees longitude,
            ChangingTableType changingTable,
            SeatingType seatType,
            BOOL healthy,
            BOOL kidsMenu,
            NSArray* ratings) {
  NSURL* imURL = [[NSBundle mainBundle] URLForResource:imageName withExtension:@"jpeg"];
  CKAsset* coverPhoto = [[CKAsset alloc] initWithFileURL:imURL];
  CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

  CKRecord* establishment = [[CKRecord alloc] initWithRecordType:@"Establishment"];
  establishment[@"CoverPhoto"] = coverPhoto;
  establishment[@"Name"] = placeName;
  establishment[@"Location"] = location;
  establishment[@"ChangingTable"] = @(changingTable);
  establishment[@"SeatingType"] = @(seatType);
  establishment[@"HealthyOption"] = @(healthy);
  establishment[@"KidsMenu"] = @(kidsMenu);

  [db saveRecord:establishment completionHandler:^(CKRecord *record, NSError *error) {
    if (error) {
      NSLog(@"Error setting up record: %@", error);
      return;
    }
    
    NSLog(@"Saved: %@", record);
    for (NSNumber* rating in ratings) {
      CKRecord* ratingRecord = [[CKRecord alloc] initWithRecordType:@"Rating"];
      ratingRecord[@"Rating"] = rating;
      
      CKReference* ref = [[CKReference alloc] initWithRecord:record action:CKReferenceActionDeleteSelf];
      ratingRecord[@"Establishment"] = ref;
      
      [db saveRecord:ratingRecord completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
          NSLog(@"Error setting up rating: %@", error);
          return;
        }
      }];
    }
  }];
}

+ (void)doWorkaround
{
  CKContainer* container = [CKContainer defaultContainer];
  CKDatabase* db = container.publicCloudDatabase;
  
  //Apple Campus location = 37.33182, -122.03118
  upload(db, @"pizza", @"Ceasar's Pizza Palace", 37.332, -122.03, ChangingTableTypeWomens, SeatingTypeHighChair | SeatingTypeBooster, NO, YES, @[@0, @1, @2]);
  upload(db, @"chinese", @"King Wok", 37.1, -122.1, ChangingTableTypeNone, SeatingTypeHighChair, YES, NO, @[]);
  upload(db, @"steak", @"The Back Deck", 37.4, -122.03, ChangingTableTypeWomens | ChangingTableTypeMens, SeatingTypeHighChair | SeatingTypeBooster, YES, YES, @[@5, @5, @4]);

}

@end
