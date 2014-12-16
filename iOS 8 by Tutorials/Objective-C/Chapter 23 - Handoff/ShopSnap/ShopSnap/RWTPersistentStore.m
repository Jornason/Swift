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

#import "RWTPersistentStore.h"

static NSString * const kRWTStoreFileName = @"RWTStore";

@interface RWTPersistentStore ()
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSURL *storeURL;
@end

@implementation RWTPersistentStore

#pragma mark - Custom Accessors

- (NSURL *)storeURL {
  if (!_storeURL) {
    NSError *error = nil;
    NSURL *URL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (URL) {
      URL = [URL URLByAppendingPathComponent:kRWTStoreFileName];
      _storeURL = URL;
    } else {
      NSLog(@"Error getting user documents directory: %@", error.localizedDescription);
    }
  }
  return _storeURL;
}

#pragma mark - Public

+ (instancetype)defaultStore {
  static RWTPersistentStore *__sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    __sharedInstance = [[RWTPersistentStore alloc] init];
  });
  return __sharedInstance;
}

- (void)fetchItems:(void (^)(NSArray *))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    // Load previously saved items, if any.
    NSMutableArray *savedItems = [NSKeyedUnarchiver unarchiveObjectWithFile:self.storeURL.relativePath];
    if (savedItems.count) {
      self.items = savedItems.mutableCopy;
    } else {
      self.items = [NSMutableArray array];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      if (completion) {
        completion([self.items copy]);
      }
    });
  });
}

- (void)updateStoreWithItems:(NSArray *)items {
  if (items) {
    self.items = items.mutableCopy;
  } else {
    [self.items removeAllObjects];
  }
}

- (void)commit {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    BOOL success = [NSKeyedArchiver archiveRootObject:self.items toFile:self.storeURL.relativePath];
    if (!success) {
      NSLog(@"Error committing store.");
    }
  });
}

@end
