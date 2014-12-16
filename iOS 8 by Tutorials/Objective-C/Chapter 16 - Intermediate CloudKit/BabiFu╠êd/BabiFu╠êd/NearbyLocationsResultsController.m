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

#import "NearbyLocationsResultsController.h"

NSString* const RecordType = @"Establishment";

@interface NearbyLocationsResultsController ()
@property (strong, nonatomic) CKDatabase* db;
@property (strong, nonatomic) CKQueryCursor* cursor;
@property (nonatomic) BOOL startedGettingResults;
@property (nonatomic) BOOL inProgress;
@property (nonatomic) BOOL subscribed;
@end

BOOL isRetryableCKError(NSError* err) {
  BOOL isRetryable = YES;
  
  if (err) {
    BOOL isErrorDomain = err.domain == CKErrorDomain;
    BOOL errorCodeIsRetryable = err.code == 6 /* CKErrorCode.ServiceUnavailable */  ||
                                err.code == 7; /* CKErrorCode.RequestRateLimited */
    
    isRetryable = err != nil && isErrorDomain && errorCodeIsRetryable;
  }
  
  return isRetryable;
}

@implementation NearbyLocationsResultsController

- (instancetype) initWithDatabase:(CKDatabase*)database delegate:(id<NearbyLocationsResultsControllerDelegate>)delegate{
  if (self = [super init]) {
    _db = database;
    _delegate = delegate;
    
    _resultLimit = 30;
    _subscriptionId = @"subscription_id";
    _subscribed = NO;
    _results = [NSMutableArray array];
  }
  return self;
}
- (void) subscribe {
  if (self.subscribed) {
    return;
  }
  
  CKSubscriptionOptions options = CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordDeletion | CKSubscriptionOptionsFiresOnRecordUpdate;
  CKSubscription* subscription = [[CKSubscription alloc] initWithRecordType:RecordType predicate:self.predicate options:options];
  subscription.notificationInfo = [[CKNotificationInfo alloc] init];
  subscription.notificationInfo.alertBody = @"";
  
  [self.db saveSubscription:subscription completionHandler:^(CKSubscription *subscription, NSError *error) {
    if (error) {
      NSLog(@"error subscribing: %@", error);
    } else {
      self.subscribed = YES;
      [self listenForBecomeActive];
      NSLog(@"subscribed!");
    }
  }];
}

- (void) listenForBecomeActive {
  [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
    [self getOutstandingNotifications];
  }];
}

- (void) handleNotification:(CKNotification*)note {
  if (![note isKindOfClass:[CKQueryNotification class]]) {
    [self markNotificationAsRead:note.notificationID];
    return;
  }
  CKQueryNotification* qnote = (CKQueryNotification*)note;
  CKRecordID* recordID = qnote.recordID;
  switch (qnote.queryNotificationReason) {
    case CKQueryNotificationReasonRecordDeleted:
      [self remove:recordID];
      break;
    case CKQueryNotificationReasonRecordCreated:
    case CKQueryNotificationReasonRecordUpdated:
      [self fetchAndUpdateOrAdd:recordID];
      break;
  }
  [self markNotificationAsRead:note.notificationID];
}

- (Establishment*) itemMatching:(CKRecordID*)recordID {
  __block Establishment* retVal;
  [self.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    Establishment* e = obj;
    if ([e.record.recordID isEqual:recordID]) {
      retVal = e;
      *stop = YES;
    }
  }];
  return retVal;
}


- (void) remove:(CKRecordID*)recordID {
  dispatch_async(dispatch_get_main_queue(), ^{
    Establishment* e = [self itemMatching:recordID];
    if (!e) {
      return;
    }

    [self.delegate willBeginUpdating];
    NSUInteger idx = [self.results indexOfObject:e];
    [self.results removeObjectAtIndex:idx];
    [self.delegate establishmentRemovedAtIndex:idx];
    [self.delegate didEndUpdating:nil];
  });
}

- (void) fetchAndUpdateOrAdd:(CKRecordID*)recordID {
  [self.db fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
    if (error) {
      return;
    }
    
    Establishment* e = [self itemMatching:recordID];
    if (e) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate willBeginUpdating];
        e.record = record;
        [self.delegate establishmentUpdated:e index:[self.results indexOfObject:e]];
        [self.delegate didEndUpdating:nil];
      });
    } else {
      e = [[Establishment alloc] initWithRecord:record database:self.db];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate willBeginUpdating];
        [self.results addObject:e];
        [self.delegate establishmentAdded:e index:self.results.count -1];
        [self.delegate didEndUpdating:nil];
      });
    }
  }];
}

- (void) markNotificationAsRead:(CKNotificationID*) note {
  CKMarkNotificationsReadOperation* markOp = [[CKMarkNotificationsReadOperation alloc] initWithNotificationIDsToMarkRead:@[note]];
  [[CKContainer defaultContainer] addOperation:markOp];
}

- (void) getOutstandingNotifications {
  CKFetchNotificationChangesOperation* op = [[CKFetchNotificationChangesOperation alloc] initWithPreviousServerChangeToken:nil];
  op.notificationChangedBlock = ^(CKNotification* notification) {
    [self handleNotification:(CKQueryNotification*)notification];
  };
  op.fetchNotificationChangesCompletionBlock = ^(CKServerChangeToken* serverChangeToken, NSError* error) {
    if (error) {
      NSLog(@"error fetching notifications %@", error);
    }
  };
  [[CKContainer defaultContainer] addOperation:op];
}

- (void) start {
  if (self.inProgress) {
    return;
  }
  self.inProgress = YES;

  CKQuery* query = [[CKQuery alloc] initWithRecordType:RecordType predicate:self.predicate];
  CKQueryOperation* queryOp = [[CKQueryOperation alloc] initWithQuery:query];
  queryOp.desiredKeys = @[@"Name",@"Location",@"HealthyOption",@"KidsMenu"];
  [self sendOperation:queryOp];

  [self subscribe];
  [self getOutstandingNotifications];
}

- (void) sendOperation:(CKQueryOperation*)queryOp {
  __weak CKQueryOperation* weakOp = queryOp;

  queryOp.queryCompletionBlock = ^(CKQueryCursor* cursor, NSError* error) {
    if (isRetryableCKError(error)) {
      NSDictionary* userInfo = error.userInfo;

      NSNumber* retryAfter = userInfo[CKErrorRetryAfterKey];
      if (retryAfter) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([retryAfter doubleValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          [self sendOperation:weakOp];
        });
        return;
      }
    }
    
    [self queryCompleted:cursor error:error];
    if (cursor) {
      [self fetchNextResults:cursor];
    } else {
      self.inProgress = NO;
      [self persist];
    }
  };

  queryOp.recordFetchedBlock = ^(CKRecord* record){
    [self recordFetched:record];
  };
  queryOp.resultsLimit = self.resultLimit;
  
  self.startedGettingResults = YES;
  [self.db addOperation:queryOp];
}

- (void) queryCompleted:(CKQueryCursor*)cursor error:(NSError*)error {
  self.startedGettingResults = NO;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate didEndUpdating:error];
  });
}

- (void) fetchNextResults:(CKQueryCursor*)cursor {
  CKQueryOperation* queryOp = [[CKQueryOperation alloc] initWithCursor:cursor];
  queryOp.desiredKeys = @[@"Name",@"Location",@"HealthyOption",@"KidsMenu"];
  [self sendOperation:queryOp];
}

- (void) persist {
  NSMutableData* data = [NSMutableData data];
  NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [archiver encodeRootObject:self.results];
  [archiver finishEncoding];
  [data writeToFile:[self cachePath] atomically:YES];
}

- (NSString*) cachePath {
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  return [paths[0] stringByAppendingPathComponent:@"establishments.cache"];
}

- (void) recordFetched:(CKRecord*)record {
  if (!self.startedGettingResults) {
    self.startedGettingResults = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.delegate willBeginUpdating];
    });
  }
  
  Establishment* e = [self itemMatching:record.recordID];
  BOOL newItem = NO;
  if (e) {
    e.record = record;
  } else {
    newItem = YES;
    e = [[Establishment alloc] initWithRecord:record database:self.db];
    [self.results addObject:e];
  }
  
  NSInteger index = [self.results indexOfObject:e];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if (newItem) {
      [self.delegate establishmentAdded:e index:index];
    } else {
      [self.delegate establishmentUpdated:e index:index];
    }
  });
}

- (void) loadCache {
  NSString* path = [self cachePath];
  NSData* data = [NSData dataWithContentsOfFile:path];
  if ([data length] > 0) {
    NSKeyedUnarchiver* decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray* obj = [decoder decodeObject];
    if (obj) {
      self.results = [obj mutableCopy];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate controllerUpdated];
      });
    }
  }
}

@end
