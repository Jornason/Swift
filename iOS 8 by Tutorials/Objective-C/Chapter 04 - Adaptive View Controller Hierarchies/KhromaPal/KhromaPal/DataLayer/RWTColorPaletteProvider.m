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

#import "RWTColorPaletteProvider.h"
#import "RWTColorPaletteCollection.h"
#import "RWTColorPalette.h"
#import "Colours.h"

@interface RWTColorPaletteProvider ()

@property (strong, nonatomic, readwrite) RWTColorPaletteCollection *rootCollection;

@end



@implementation RWTColorPaletteProvider

+ (instancetype)defaultProvider {
  NSString *defaultPlist = @"DefaultColourSwatchCollection";
  return [[[self class] alloc] initWithPlistName:defaultPlist];
}

- (instancetype)initWithPlistName:(NSString *)plistName {
  self = [super init];
  if(self) {
    self.rootCollection = [self parsePlistWithName:plistName];
  }
  return self;
}

#pragma mark - Private methods
- (RWTColorPaletteCollection *)parsePlistWithName:(NSString *)name {
  NSArray *plistRoot = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"plist"]];
  NSArray *parsedItems = [self parseArrayIntoTreeItems:plistRoot];
  
  return [RWTColorPaletteCollection collectionWithName:@"root" children:parsedItems];
}

- (NSArray *)parseArrayIntoTreeItems:(NSArray *)array {
  NSMutableArray *parsedItems = [NSMutableArray array];
  [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
    id<RWTPaletteTreeNode> parsedDict = [self parseDictionaryIntoTreeItem:dict];
    [parsedItems addObject:parsedDict];
  }];
  return [parsedItems copy];
}

- (id<RWTPaletteTreeNode>)parseDictionaryIntoTreeItem:(NSDictionary *)dict {
  if(dict[@"children"]) {
    NSArray *parsedChildren = [self parseArrayIntoTreeItems:dict[@"children"]];
    return [RWTColorPaletteCollection collectionWithName:dict[@"name"] children:parsedChildren];
  } else if(dict[@"colors"]) {
    NSMutableArray *colorScheme = [NSMutableArray array];
    [dict[@"colors"] enumerateObjectsUsingBlock:^(NSString *hexString, NSUInteger idx, BOOL *stop) {
      [colorScheme addObject:[UIColor colorFromHexString:hexString]];
    }];
    return [RWTColorPalette paletteWithName:dict[@"name"] colors:[colorScheme copy]];
  } else if(dict[@"color"]) {
    UIColor *baseColor = [UIColor colorFromHexString:dict[@"color"]];
    NSArray *scheme = [baseColor colorSchemeOfType:ColorSchemeAnalagous];
    NSMutableArray *fullSet = [NSMutableArray arrayWithArray:scheme];
    [fullSet insertObject:baseColor atIndex:2];
    return [RWTColorPalette paletteWithName:dict[@"name"] colors:[fullSet copy]];
  }
  return nil;
}

@end
