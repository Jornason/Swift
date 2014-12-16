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

#import "RWTNavigationController.h"

@implementation RWTNavigationController

#pragma mark - <RWTPaletteDisplayContainer>
- (RWTColorPalette *)rw_currentlyDisplayedPalette {
    if([self.topViewController conformsToProtocol:@protocol(RWTPaletteDisplayContainer)]) {
        id<RWTPaletteDisplayContainer> paletteDisplayContainer = (id<RWTPaletteDisplayContainer>)self.topViewController;
        return [paletteDisplayContainer rw_currentlyDisplayedPalette];
    }
    return nil;
}

#pragma mark - <RWTPaletteSelectionContainer>
- (RWTColorPalette *)rw_currentlySelectedPalette {
    if([self.topViewController conformsToProtocol:@protocol(RWTPaletteSelectionContainer)]) {
        id<RWTPaletteSelectionContainer> paletteSelectionContainer = (id<RWTPaletteSelectionContainer>)self.topViewController;
        return [paletteSelectionContainer rw_currentlySelectedPalette];
    }
    return nil;
}

@end
