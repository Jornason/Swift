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


#import "RWTWeatherStatus.h"

@interface RWTWeatherStatus ()

@property (nonatomic, strong, readwrite) NSNumber *temperature;
@property (nonatomic, assign) RWTWeatherStatusType type;

@end

@implementation RWTWeatherStatus

- (instancetype)initWithTemperature:(NSNumber *)temperature type:(RWTWeatherStatusType)type {
  self = [super init];
  if(self) {
    self.temperature = temperature;
    self.type = type;
  }
  return self;
}

+ (instancetype)statusWithTemperature:(NSNumber *)temperature type:(RWTWeatherStatusType)type {
  return [[[self class] alloc] initWithTemperature:temperature type:type];
}

#pragma mark - Override properties
- (UIImage *)statusImage {
  switch (self.type) {
    case RWTWeatherStatusTypeCloud:
      return [UIImage imageNamed:@"cloud"];
    case RWTWeatherStatusTypeLightning:
      return [UIImage imageNamed:@"lightning"];
    case RWTWeatherStatusTypeSun:
      return [UIImage imageNamed:@"sun"];
  }
}

@end
