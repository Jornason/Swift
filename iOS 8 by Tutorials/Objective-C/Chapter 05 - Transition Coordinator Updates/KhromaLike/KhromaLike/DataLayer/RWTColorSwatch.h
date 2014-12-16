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

@import UIKit;

@interface RWTColorSwatch : NSObject

/*
 A string representing the name of this color
 */
@property (strong, readonly, nonatomic) NSString *name;

/*
 The color this swatch is representing
 */
@property (strong, readonly, nonatomic) UIColor *color;


@property (readonly, nonatomic) NSString *hexString;
@property (readonly, nonatomic) NSString *rgbString;
@property (readonly, nonatomic) NSString *cmykString;
@property (readonly, nonatomic) NSString *hsbString;
@property (readonly, nonatomic) NSString *cielabString;

/*
 Factory initialiser to create a swatch
 @param color The color this swatch will represent
 @param name  The name associated with this color
 */
+ (instancetype)colorSwatchWithColor:(UIColor *)color name:(NSString *)name;

/*
 Standard initialiser for a swatch
 @param color The color this swatch will represent
 @param name  The name associated with this color
 */
- (instancetype)initWithColor:(UIColor *)color name:(NSString *)name NS_DESIGNATED_INITIALIZER;


/*
 An array of UIColor objects which work well with color represented by the
 receiver.
 */
- (NSArray *)relatedColors;


@end
