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

#import "RWTWeatherData.h"
#import "RWTCityWeather.h"

@interface RWTWeatherData ()

@property (strong, nonatomic, readwrite) NSArray *cities;

@end

@implementation RWTWeatherData

- (instancetype)initWithPListNamed:(NSString *)plistName {
  self = [super init];
  if(self) {
    self.cities = [self loadWeatherDataFromPListNamed:plistName];
  }
  return self;
}

+ (instancetype)loadFromDefaultPList {
  return [[[self class] alloc] initWithPListNamed:@"WeatherData"];
}

#pragma mark - Private methods
- (NSArray *)loadWeatherDataFromPListNamed:(NSString *)plistName {
  NSDictionary *imported = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
  
  NSMutableArray *cityData = [NSMutableArray array];
  [imported enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
    [cityData addObject:[self cityWeatherFromArray:obj withName:key]];
  }];
  
  return [cityData copy];
}

- (RWTCityWeather *)cityWeatherFromArray:(NSArray *)array withName:(NSString *)name {
  NSMutableArray *weather = [NSMutableArray array];
  [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
    [weather addObject:[self dailyWeatherFromDictionary:obj]];
  }];
  return [RWTCityWeather weatherForCityNamed:name weather:[weather copy]];
}

- (RWTDailyWeather *)dailyWeatherFromDictionary:(NSDictionary *)dict {
  return [RWTDailyWeather dailyWeatherWithDate:dict[@"date"] status:[self weatherStatusFromDictionary:dict]];
}

- (RWTWeatherStatus *)weatherStatusFromDictionary:(NSDictionary *)dict {
  RWTWeatherStatusType statusType = 0;
  NSString *typeFromDict = dict[@"type"];
  if([typeFromDict isEqualToString:@"lightning"]) {
    statusType = RWTWeatherStatusTypeLightning;
  } else if([typeFromDict isEqualToString:@"sun"]) {
    statusType = RWTWeatherStatusTypeSun;
  } else if([typeFromDict isEqualToString:@"cloud"]) {
    statusType = RWTWeatherStatusTypeCloud;
  }
  
  return [RWTWeatherStatus statusWithTemperature:dict[@"temperature"] type:statusType];
}

@end
