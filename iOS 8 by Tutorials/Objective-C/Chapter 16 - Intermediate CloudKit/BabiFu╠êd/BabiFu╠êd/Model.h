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

#import <Foundation/Foundation.h>

#import "Establishment.h"
#import "UserInfo.h"
#import "NearbyLocationsResultsController.h"

@protocol ModelDelegate <NSObject>

- (void) modelUpdated;
- (void) modelUpdatedAtIndexPath:(NSIndexPath*)indexPath;
- (void) errorUpdatingModel:(NSError*)error;

@end

@interface Model : NSObject

@property (weak, nonatomic) id<ModelDelegate> delegate;
@property (strong, nonatomic) UserInfo* user;
@property (strong, nonatomic) NSMutableArray* items;
@property (strong, nonatomic) CKDatabase* db;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype) model;


- (void) refresh;
- (void) addPhoto:(NSURL*)localURL to:(Establishment*)e;
- (void) addNote:(NSString *)note to:(Establishment *)e completion:(void(^)(NSError* error))completion;

- (NearbyLocationsResultsController*) makeController:(id<NearbyLocationsResultsControllerDelegate>)delegate;

- (void) refreshEstablishmentsNear:(CLLocation*)location within:(CGFloat)radiusInKilometers;
- (void) establishmentsNear:(CLLocation*)location within:(CGFloat)radiusInKilometers completion:(void(^)(NSArray* array, NSError* error))completion;

- (void) fetchNotes:(void(^)(NSArray* notes, NSError* error))completion;
- (Establishment*) establishmentForRef:(CKReference*)ref;
- (NSPredicate*) createLocationPredicate:(CLLocation*)location radiusInMeters:(CLLocationDistance)radiusInMeters;

@end
