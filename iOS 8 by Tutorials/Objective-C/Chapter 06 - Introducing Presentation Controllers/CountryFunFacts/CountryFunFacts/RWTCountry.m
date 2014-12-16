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

#import "RWTCountry.h"

@implementation RWTCountry

+ (NSArray *)countries {
  
  NSString *plistFile = [[NSBundle mainBundle] pathForResource:@"CountryData" ofType:@"plist"];
  NSArray *plistArray = [[NSArray alloc] initWithContentsOfFile:plistFile];
  
  NSMutableArray *countryArray = [[NSMutableArray alloc] init];
  
  for (NSDictionary *dictionary in plistArray) {
    RWTCountry *country = [[RWTCountry alloc] init];
    country.countryName = dictionary[@"countryName"];
    country.imageName = dictionary[@"imageName"];
    country.hello = dictionary[@"hello"];
    country.population = dictionary[@"population"];
    country.currency = dictionary[@"currency"];
    country.language = dictionary[@"language"];
    country.fact = dictionary[@"fact"];
    country.quizQuestion = dictionary[@"quizQuestion"];
    country.correctAnswer = dictionary[@"correctAnswer"];
    country.quizAnswers = dictionary[@"quizAnswers"];
    
    [countryArray addObject:country];
  }
  
  return [NSArray arrayWithArray:countryArray];
}

@end
