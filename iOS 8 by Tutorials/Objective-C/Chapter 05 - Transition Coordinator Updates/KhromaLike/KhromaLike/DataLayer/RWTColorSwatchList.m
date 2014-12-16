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

#import "RWTColorSwatchList.h"
#import "RWTColorSwatch.h"
#import "Colours.h"

@interface RWTColorSwatchList ()

@property (strong, readwrite, nonatomic) NSArray *colorSwatches;

@end


@implementation RWTColorSwatchList

+ (instancetype)defaultColorSwatchList {
  return [[[self class] alloc] initWithPlistNamed:@"ColorList"];
}

- (instancetype)initWithPlistNamed:(NSString *)plistName {
  self = [super init];
  if(self) {
    self.colorSwatches = [self loadSwatchesFromPlistNamed:plistName];
  }
  return self;
}


#pragma mark - Private utility methods
- (NSArray *)loadSwatchesFromPlistNamed:(NSString *)plistName {
  /*
   We expect the plist to be a dictionary with the color names as the keys and
   hex strings representing the colors to be the values. Very little error checking
   is performed in this code.
   */
  
  // Get the path to the plist (inside the main bundle)
  NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
  
  // Load the plist
  NSDictionary *colorList = [NSDictionary dictionaryWithContentsOfFile:plistPath];
  if(!colorList) {
    NSLog(@"There was an error loading the plist %@. Check that the file exists "
           "in the main bundle and that the root element is a dictionary.", plistName);
    return nil;
  }
  
  NSMutableArray *swatchList = [NSMutableArray array];
  [colorList enumerateKeysAndObjectsUsingBlock:^(NSString *colorName, NSString *colorHexString, BOOL *stop) {
    // Create the UIColor from the hex string
    UIColor *color = [UIColor colorFromHexString:colorHexString];
    // Create the swatch
    RWTColorSwatch *swatch = [RWTColorSwatch colorSwatchWithColor:color name:colorName];
    [swatchList addObject:swatch];
  }];
  
  // Return the imported swatch list
  return [swatchList copy];;
}

@end
