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
 *
 *  RWTPlaceManagerTests.m
 *  Places
 *
 *  Created by Soheil Azarpour on 6/24/14.
 *  Copyright (c) 2014 Razeware LLC. All rights reserved.
 */

@import XCTest;
#import "RWTPlaceManager.h"
#import "NSBundle+RWTTestAdditions.h"

/** @brief This private extension exposes those private methods in RWTPlaceManager that we want to test to this Unit Test class. */
@interface RWTPlaceManager (RWTTextExtension)
- (NSArray *)processJSONRoot:(NSDictionary *)root;
@end


@interface RWTPlaceManagerTests : XCTestCase
@property (strong, nonatomic) RWTPlaceManager *placeManager;
@end

@implementation RWTPlaceManagerTests

- (RWTPlaceManager *)placeManager {
  if (!_placeManager) {
    _placeManager = [RWTPlaceManager sharedManager];
  }
  return _placeManager;
}

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)test_placeManager_initialization {
  RWTPlaceManager *sharedManager = [RWTPlaceManager sharedManager];
  XCTAssert(sharedManager, @"RWTPlaceManager failed to return shared instance.");
}

- (void)test_localResourceFileURL_getter {
  NSURL *localResourceURL = self.placeManager.localResourceFileURL;
  XCTAssert(localResourceURL, @"RWTPlaceManager failed to return default local resource URL.");
}

- (void)test_async_fetchPlaces {
  
  // Fetching is async. So create an expectation.
  XCTestExpectation *expectation = [self expectationWithDescription:@"Async fetch"];
  
  // Provide our sample test JSON.
  NSURL *sampleURL = [[NSBundle testBundle] URLForResource:@"SampleResponse" withExtension:@"json"];
  XCTAssert(sampleURL, @"Failed to get a valid URL to sample response file in Test Bundle.");
  
  self.placeManager.localResourceFileURL = sampleURL;
  
  [self.placeManager fetchPlacesWithCompletion:^(NSArray *places) {
    
    XCTAssertTrue(places.count == 600, "Expected to get 600 results from the sample response.");
    
    // Fulfill the expectation-this will cause -waitForExpectation
    // to invoke its completion handler and then return.
    [expectation fulfill];
  }];
  
  // The test will pause here, running the run loop, until the timeout is hit
  // or all expectations are fulfilled.
  [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    XCTAssertNil(error, @"RWTPlaceManager failed to process fetch from sample response in a reasonable time.");
  }];
}

- (void)test_performance_processJSONRoot {
  
  // Provide our sample test JSON.
  NSURL *sampleURL = [[NSBundle testBundle] URLForResource:@"SampleResponse" withExtension:@"json"];
  NSData *data = [NSData dataWithContentsOfURL:sampleURL];
  NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  [self measureBlock:^{
    
    NSArray *placeObjects = [self.placeManager processJSONRoot:root];
    XCTAssertTrue(placeObjects.count == 600, "Expected to get 600 results from the sample response.");
   
  }];
}

@end
