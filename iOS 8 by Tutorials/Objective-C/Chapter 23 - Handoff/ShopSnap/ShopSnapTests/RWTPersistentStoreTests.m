//
//  RWTPersistentStoreTests.m
//  ShopSnap
//
//  Created by Soheil Azarpour on 6/18/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

@import XCTest;
#import "RWTPersistentStore.h"

/*
 * The followings are re-declaration of private properties of
 * RWTPersistentStore so that they are exposed to the unit test.
 */
@interface RWTPersistentStore (UnitTest)
@property (strong, nonatomic) NSURL *userDocumentsURL;
@property (strong, nonatomic) NSMutableArray *items;
@end

@interface RWTPersistentStoreTests : XCTestCase
@end

@implementation RWTPersistentStoreTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPersistentStoreInitialization {
  RWTPersistentStore *persistentStore = [RWTPersistentStore defaultStore];
  XCTAssert(persistentStore, @"RWTPersistentStore failed to instantiate.");
  
  // Along with its instantiation, inMemoryStore and userDocumentsURL are expected to be set.
  XCTAssert(persistentStore.userDocumentsURL, @"userDocumentsURL was expected to be set at instantiation of store.");
  XCTAssert(persistentStore.items, @"items array was expected to be set at instantiation of store.");
  
  // Re-accessing the store, should return the same object.
  RWTPersistentStore *anotherStore = [RWTPersistentStore defaultStore];
  XCTAssertEqualObjects(persistentStore, anotherStore, @"defaultStore was expected to return the same object.");
}

@end
