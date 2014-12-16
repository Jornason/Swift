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

#import <Foundation/Foundation.h>

@interface RWTCountry : NSObject

@property (copy, nonatomic) NSString *countryName;
@property (copy, nonatomic) NSString *imageName;
@property (copy, nonatomic) NSString *hello;
@property (copy, nonatomic) NSString *population;
@property (copy, nonatomic) NSString *currency;
@property (copy, nonatomic) NSString *language;
@property (copy, nonatomic) NSString *fact;
@property (copy, nonatomic) NSString *quizQuestion;
@property (copy, nonatomic) NSString *correctAnswer;
@property (strong, nonatomic) NSArray *quizAnswers;

// New property to determine visibility on insertion animation
@property (assign, nonatomic) BOOL isHidden;

+ (NSArray *)countries;

@end
