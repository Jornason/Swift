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
 *  RWTPlaceManager.m
 *  Places
 *
 *  Created by Soheil Azarpour on 6/24/14.
 *  Copyright (c) 2014 Razeware LLC. All rights reserved.
 */

#import "RWTPlaceManager.h"

@interface RWTPlaceManager ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *subtitleFormatter;
@end

@implementation RWTPlaceManager

#pragma mark - Custom Accessors

- (NSDateFormatter *)dateFormatter {
  if (!_dateFormatter) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss zzz";
    _dateFormatter = dateFormatter;
  }
  return _dateFormatter;
}

- (NSDateFormatter *)subtitleFormatter {
  if (!_dateFormatter) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    _subtitleFormatter = dateFormatter;
  }
  return _subtitleFormatter;
}

- (NSURL *)localResourceFileURL {
  if (!_localResourceFileURL) {
    _localResourceFileURL = [[NSBundle mainBundle] URLForResource:@"Places" withExtension:@"json"];
  }
  return _localResourceFileURL;
}

#pragma mark - Public

+ (instancetype)sharedManager {
  static RWTPlaceManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[self alloc] init];
  });
  return sharedManager;
}

- (void)fetchPlacesWithCompletion:(void (^)(NSArray *))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSData *data = [NSData dataWithContentsOfURL:self.localResourceFileURL];
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *processed = [self processJSONRoot:root];
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(processed);
    });
  });
}

#pragma mark - Private

- (NSArray *)processJSONRoot:(NSDictionary *)root {
  NSArray *places = [root objectForKey:@"places"];
  NSMutableArray *placesObjects = [NSMutableArray array];
  for (NSDictionary *aPlace in places) {
    NSString *title = aPlace[@"title"];
    NSString *dateString = aPlace[@"date"];
    NSString *imageFile = aPlace[@"image"];
    NSDictionary *locaion = aPlace[@"location"];
    NSNumber *latitude = locaion[@"latitude"];
    NSNumber *longitude = locaion[@"longitude"];
    
    // Formate date string to date.
    NSDate *date = [self.dateFormatter dateFromString:dateString];
    
    // Create location coordinate.
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    // Get the image.
    UIImage *image = [UIImage imageNamed:imageFile];
    // Create the RWTPlace object.
    RWTPlace *aPlace = [RWTPlace placeWithTitle:title date:date image:image coordinate:locationCoordinate];
    aPlace.subtitle = [self.subtitleFormatter stringFromDate:date];
    [placesObjects addObject:aPlace];
  }
  
  // Sort places based on date.
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
  [placesObjects sortUsingDescriptors:@[sortDescriptor]];
  return placesObjects;
}

@end
