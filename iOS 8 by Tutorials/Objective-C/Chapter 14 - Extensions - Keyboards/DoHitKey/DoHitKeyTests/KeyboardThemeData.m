//  KeyboardThemeData.m

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

#import "KeyboardThemeData.h"

@interface KeyboardThemeData ()

@end

@implementation KeyboardThemeData

NSString * const kThemePreference = @"pref_theme";

NSString * const kButtonFontName = @"Helvetica";
int const kButtonFontSize = 16;
int const kSpecialButtonFontSize = 12;

#pragma mark - Configure App Data

+ (NSArray *)configureThemeData {
  
  // http://www.briangrinstead.com/blog/ios-uicolor-picker
  
  /*
   You could use a plist or core data that contains the app data.
   The method below is harcoding the data to make it a little easier.
   DO NOT do this in production unless the app data is lighweight.
   
   Also... notice the index number, from the array, is being used for the themeID.
   */
  
  NSMutableArray *themeData = [NSMutableArray array];
  
  /* SOLID */
  
  KeyboardThemeData *theme = [[KeyboardThemeData alloc] init];
  theme.themeID = 0;
  theme.themeName = @"Solid";
  
  theme.colorForBackground = [UIColor colorWithRed:107.0/255.0 green:205.0/255.0 blue:159.0/255.0 alpha:1];
  
  theme.colorForCustomRow = [UIColor colorWithRed:69.0/255.0f green:195.0/255.0f blue:136.0/255.0f alpha:1.0];
  theme.colorForRow1 = [UIColor colorWithRed:69.0/255.0f green:195.0/255.0f blue:136.0/255.0f alpha:1.0];
  theme.colorForRow2 = [UIColor colorWithRed:69.0/255.0f green:195.0/255.0f blue:136.0/255.0f alpha:1.0];
  theme.colorForRow3 = [UIColor colorWithRed:69.0/255.0f green:195.0/255.0f blue:136.0/255.0f alpha:1.0];
  theme.colorForRow4 = [UIColor colorWithRed:69.0/255.0f green:195.0/255.0f blue:136.0/255.0f alpha:1.0];
  
  theme.colorForButtonFont = [UIColor whiteColor];
  
  theme.keyboardButtonFont = [UIFont fontWithName:kButtonFontName size:kButtonFontSize];
  
  
  [themeData addObject:theme];
  
  /* FADE */
  
  KeyboardThemeData *theme1 = [[KeyboardThemeData alloc] init];
  theme1.themeID = 1;
  theme1.themeName = @"Fade";
  
  theme1.colorForBackground = [UIColor colorWithRed:138.0/255.0 green:212.0/255.0 blue:177.0/255.0 alpha:1];
  
  theme1.colorForCustomRow = [UIColor colorWithRed:155.0/255 green:217.0/255 blue:187.0/255 alpha:1.0];
  theme1.colorForRow1 = [UIColor colorWithRed:138.0/255 green:212.0/255 blue:177.0/255 alpha:1.0];
  theme1.colorForRow2 = [UIColor colorWithRed:121.0/255 green:208.0/255 blue:166.0/255 alpha:1.0];
  theme1.colorForRow3 = [UIColor colorWithRed:103.0/255 green:203.0/255 blue:156.0/255 alpha:1.0];
  theme1.colorForRow4 = [UIColor colorWithRed:86.0/255 green:198.0/255 blue:146.0/255 alpha:1.0];
  
  theme1.colorForButtonFont = [UIColor whiteColor];
  
  theme1.keyboardButtonFont = [UIFont fontWithName:kButtonFontName size:kButtonFontSize];
  
  [themeData addObject:theme1];
  
  /* STRIPED */
  
  KeyboardThemeData *theme2 = [[KeyboardThemeData alloc] init];
  theme2.themeID = 2;
  theme2.themeName = @"Striped";
  
  theme2.colorForBackground = [UIColor colorWithRed:122.0/255.0 green:208.0/255.0 blue:168.0/255.0 alpha:1];
  
  theme2.colorForCustomRow = [UIColor colorWithRed:103.0/255 green:203.0/255 blue:156.0/255 alpha:1.0];
  theme2.colorForRow1 = [UIColor colorWithRed:69.0/255 green:195.0/255 blue:136.0/255 alpha:1.0];
  theme2.colorForRow2 = [UIColor colorWithRed:103.0/255 green:203.0/255 blue:156.0/255 alpha:1.0];
  theme2.colorForRow3 = [UIColor colorWithRed:69.0/255 green:195.0/255 blue:136.0/255 alpha:1.0];
  theme2.colorForRow4 = [UIColor colorWithRed:103.0/255 green:203.0/255 blue:156.0/255 alpha:1.0];
  
  theme2.colorForButtonFont = [UIColor whiteColor];
  
  theme2.keyboardButtonFont = [UIFont fontWithName:kButtonFontName size:kButtonFontSize];
  
  [themeData addObject:theme2];
  
  /* NONE */
  
  KeyboardThemeData *theme3 = [[KeyboardThemeData alloc] init];
  theme3.themeID = 3;
  theme3.themeName = @"None";
  
  theme3.colorForBackground = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1];
  
  theme3.colorForCustomRow = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0];
  theme3.colorForRow1 = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0];
  theme3.colorForRow2 = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0];
  theme3.colorForRow3 = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0];
  theme3.colorForRow4 = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0];
  
  theme3.colorForButtonFont = [UIColor colorWithRed:80.0/255.0 green:203.0/255.0 blue:154.0/255.0 alpha:1];
  
  theme3.keyboardButtonFont = [UIFont fontWithName:kButtonFontName size:kButtonFontSize];
  
  [themeData addObject:theme3];
  
  return themeData;
}

@end