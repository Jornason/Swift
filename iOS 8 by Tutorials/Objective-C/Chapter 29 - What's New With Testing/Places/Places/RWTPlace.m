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
 *  RWTPlace.m
 *  Places
 *
 *  Created by Soheil Azarpour on 6/24/14.
 *  Copyright (c) 2014 Razeware LLC. All rights reserved.
 */

#import "RWTPlace.h"

@implementation RWTPlace

#pragma mark - Public

+ (instancetype)placeWithTitle:(NSString *)title date:(NSDate *)date image:(UIImage *)image coordinate:(CLLocationCoordinate2D)coordinate {
  RWTPlace *place = [[RWTPlace alloc] init];
  place.title = title;
  place.date = date;
  place.image = image;
  place.coordinate = coordinate;
  return place;
}

#pragma mark - Debug

- (NSString *)description {
  // Return a developer friendly representation of the class for debugger.
  NSString *description = [NSString stringWithFormat:@"<%@ title:%@ latitude:%f longitude:%f>", self.class, self.title, self.coordinate.latitude, self.coordinate.longitude];
  return description;
}

@end
