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

#import "RWTColorSwatch.h"
#import "Colours.h"

@interface RWTColorSwatch ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) UIColor *color;

@end

@implementation RWTColorSwatch

@dynamic hexString;
@dynamic rgbString;
@dynamic cmykString;
@dynamic cielabString;
@dynamic hsbString;

+ (instancetype)colorSwatchWithColor:(UIColor *)color name:(NSString *)name {
  return [[[self class] alloc] initWithColor:color name:name];
}

- (instancetype)initWithColor:(UIColor *)color name:(NSString *)name {
  self = [super init];
  if(self) {
    self.color = color;
    self.name = name;
  }
  return self;
}

- (instancetype)init {
  // By default let's just return black
  return [self initWithColor:[UIColor blackColor] name:@"black"];
}

- (NSArray *)relatedColors {
  return [self.color colorSchemeOfType:ColorSchemeAnalagous];
}

#pragma mark - Property Overrides
- (NSString *)hexString {
  // Method provided by the Colours class extension
  return [self.color hexString];
}

- (NSString *)rgbString {
  // Method provided by the Colours class extension
  NSDictionary *rgbDict = [self.color rgbaDictionary];
  return [NSString stringWithFormat:@"(%0.2f, %0.2f, %0.2f)", [rgbDict[kColoursRGBA_R] floatValue],
          [rgbDict[kColoursRGBA_G] floatValue],
          [rgbDict[kColoursRGBA_B] floatValue]];
}

- (NSString *)cmykString {
  // Method provided by the Colours class extension
  NSDictionary *cmykDict = [self.color cmykDictionary];
  return [NSString stringWithFormat:@"(%0.2f, %0.2f, %0.2f, %0.2f)", [cmykDict[kColoursCMYK_C] floatValue],
          [cmykDict[kColoursCMYK_M] floatValue],
          [cmykDict[kColoursCMYK_Y] floatValue],
          [cmykDict[kColoursCMYK_K] floatValue]];
}

- (NSString *)hsbString {
  // Method provided by the Colours class extension
  NSDictionary *hsbDict = [self.color hsbaDictionary];
  return [NSString stringWithFormat:@"(%0.2f, %0.2f, %0.2f)", [hsbDict[kColoursHSBA_H] floatValue],
          [hsbDict[kColoursHSBA_S] floatValue],
          [hsbDict[kColoursHSBA_B] floatValue]];
  
}

- (NSString *)cielabString {
  // Method provided by the Colours class extension
  NSDictionary *cieDict = [self.color CIE_LabDictionary];
  return [NSString stringWithFormat:@"(%0.2f, %0.2f, %0.2f)", [cieDict[kColoursCIE_L] floatValue],
          [cieDict[kColoursCIE_A] floatValue],
          [cieDict[kColoursCIE_B] floatValue]];
  
}

@end
