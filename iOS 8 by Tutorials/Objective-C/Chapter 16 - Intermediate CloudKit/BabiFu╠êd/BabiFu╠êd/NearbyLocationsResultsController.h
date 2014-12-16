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
#import "Establishment.h"

@protocol NearbyLocationsResultsControllerDelegate
- (void) willBeginUpdating;
- (void) establishmentAdded:(Establishment*)establishment index:(NSInteger)index;
- (void) establishmentUpdated:(Establishment*)establishment index:(NSInteger)index;
- (void) didEndUpdating:(NSError*)error;
- (void) establishmentRemovedAtIndex:(NSInteger)index;
- (void) controllerUpdated;
@end


@interface NearbyLocationsResultsController : NSObject
@property (weak, nonatomic) id<NearbyLocationsResultsControllerDelegate> delegate;
@property (nonatomic) NSUInteger resultLimit;
@property (nonatomic, copy) NSString* subscriptionId;
@property (nonatomic, strong) NSPredicate* predicate;
@property (strong, nonatomic) NSMutableArray* results;


- (instancetype) initWithDatabase:(CKDatabase*)database delegate:(id<NearbyLocationsResultsControllerDelegate>)delegate;

- (void) handleNotification:(CKQueryNotification*)note;
- (void) start;
- (void) loadCache;
@end
