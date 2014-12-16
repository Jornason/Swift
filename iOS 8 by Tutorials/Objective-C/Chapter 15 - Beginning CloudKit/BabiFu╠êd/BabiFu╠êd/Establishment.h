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
@import CloudKit;
@import UIKit;
@import MapKit;

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, ChangingTableType) {
    ChangingTableTypeNone   = 0,
    ChangingTableTypeMens   = 1 << 0,
    ChangingTableTypeWomens = 1 << 1,
    ChangingTableTypeFamily = 1 << 2
};

typedef NS_OPTIONS(NSUInteger, SeatingType) {
    SeatingTypeNone      = 0,
    SeatingTypeBooster   = 1 << 0,
    SeatingTypeHighChair = 1 << 1
};

@interface Establishment : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* address;
@property (nonatomic) BOOL hasKidsMenu;
@property (nonatomic) BOOL hasHealthyOptions;
@property (nonatomic) ChangingTableType changingTableType;
@property (nonatomic) SeatingType seatingType;
@property (strong, nonatomic) NSArray* pictures;
@property (nonatomic, copy) NSArray* ratings;
@property (strong, nonatomic) CLLocation* location;

@property (strong, nonatomic) CKRecord* record;
@property (strong, nonatomic) CKDatabase* database;
@property (nonatomic) NSUInteger assetCount;
@property (nonatomic) BOOL metadataLoaded;

- (instancetype) initWithRecord:(CKRecord*)record database:(CKDatabase*)database;
- (void) loadCoverPhoto:(void(^)(UIImage* photo))completion;
- (void) fetchRating:(void(^)(double rating, BOOL isUser))completion;
- (void) fetchNote:(void(^)(NSString* note))completion;
- (void) fetchPhotos:(void(^)(NSArray* assets))completion;

@end
