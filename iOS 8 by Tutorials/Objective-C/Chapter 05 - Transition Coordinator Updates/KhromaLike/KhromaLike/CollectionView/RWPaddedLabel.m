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

#import "RWPaddedLabel.h"

@interface RWPaddedLabel ()

@property (assign, nonatomic) CGFloat verticalPadding;

@end

@implementation RWPaddedLabel

#pragma mark - Update the padding with trait changes

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  // Check the vertical size class
  if(self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
    // No padding when vertically compact
    self.verticalPadding = 0;
    
  } else {
    // Padding when have regular size class
    self.verticalPadding = 20;
  }
  
  // Need to update the layout
  [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
  CGSize intrinsicSize = [super intrinsicContentSize];
  
  // Add the padding
  intrinsicSize.height += self.verticalPadding;
  return intrinsicSize;
}

@end
