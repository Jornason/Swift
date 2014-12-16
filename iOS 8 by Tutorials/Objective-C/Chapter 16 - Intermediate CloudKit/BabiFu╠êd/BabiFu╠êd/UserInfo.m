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


#import "UserInfo.h"

@interface UserInfo ()
@property (strong, nonatomic) CKContainer* container;
@property (strong, nonatomic) CKRecordID* userRecordID;
@end

@implementation UserInfo

- (instancetype)initWithContainer:(CKContainer *)container {
  self = [super init];
  if (self) {
    _container = container;
  }
  return self;
}

- (void) loggedInToICloud:(void(^)(CKAccountStatus accountStatus, NSError* error))completion {
  [self.container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
    completion(accountStatus, error);
  }];
}

- (void) userID:(void(^)(CKRecordID *recordID, NSError *error))completion {
  __weak UserInfo* weakself = self;
  [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
    if (!error) {
      weakself.userRecordID = recordID;
    } else {
      if (error.code != CKErrorNotAuthenticated) {
        recordID = weakself.userRecordID;
      }
    }
    completion(recordID, error);
  }];
}

- (void)requestDiscoverabilityPermission:(void (^)(BOOL discoverable)) completion {
  
  [self.container requestApplicationPermission:CKApplicationPermissionUserDiscoverability completionHandler:^(CKApplicationPermissionStatus applicationPermissionStatus, NSError *error) {
    if (error) {
      // In your app, handle this error really beautifully.
    } else {
      completion(applicationPermissionStatus == CKApplicationPermissionStatusGranted);
    }
  }];
}

- (void) findContacts:(void (^)(NSArray *userInfos, NSError *error)) completion {
  [self.container discoverAllContactUserInfosWithCompletionHandler:^(NSArray *userInfos, NSError *error) {
    if (error != nil) {
      self.contacts = userInfos;
    }
    completion(userInfos, error);
  }];
}

- (void) userInfo:(void (^)(CKDiscoveredUserInfo *userInfo, NSError *error))completion {
  if (self.userRecordID) {
    [self userInfo:self.userRecordID completion:completion];
  } else {
    [self userID:^(CKRecordID *recordID, NSError *error) {
      if (error) {
        completion(nil, error);
      } else {
        [self userInfo:recordID completion:completion];
      }
    }];
  }
}

- (void) userInfo:(CKRecordID*)recordID completion:(void (^)(CKDiscoveredUserInfo *userInfo, NSError *error)) completion {
  [self.container discoverUserInfoWithUserRecordID:recordID completionHandler:completion];
}


@end
