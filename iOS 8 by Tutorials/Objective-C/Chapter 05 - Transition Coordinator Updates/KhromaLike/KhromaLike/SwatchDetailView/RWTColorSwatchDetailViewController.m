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

#import "RWTColorSwatchDetailViewController.h"
#import "RWTColorSwatch.h"
#import "Colours.h"

@interface RWTColorSwatchDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *hexLabel;
@property (weak, nonatomic) IBOutlet UILabel *rgbLabel;
@property (weak, nonatomic) IBOutlet UILabel *cmykLabel;
@property (weak, nonatomic) IBOutlet UILabel *hsbLabel;
@property (weak, nonatomic) IBOutlet UILabel *labLabel;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *allLabels;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *swatchTiles;

@end


@implementation RWTColorSwatchDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Hide all the UI if no color swatch
  [self updateAppearanceForColorSwatch:nil];
}

#pragma mark - Property overrides
- (void)setColorSwatch:(RWTColorSwatch *)colorSwatch {
  if (colorSwatch != _colorSwatch) {
    // Save it off
    _colorSwatch = colorSwatch;

    // Apply the styling
    [self updateAppearanceForColorSwatch:colorSwatch];
  }
}

#pragma mark - Private utility methods
- (void)setSubviewsAsHidden:(BOOL)hidden {
  [self.view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
    subview.hidden = hidden;
  }];
}

- (void)updateAppearanceForColorSwatch:(RWTColorSwatch *)colorSwatch {
  // Check for the nil case
  if(!colorSwatch) {
    [self setSubviewsAsHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    return;
  }
  
  // Otherwise, apply the settings
  [self setSubviewsAsHidden:NO];
  self.view.backgroundColor = colorSwatch.color;
  
  // Update the background color
  self.view.backgroundColor = colorSwatch.color;
  
  // And the colour labels
  self.hexLabel.text = [NSString stringWithFormat:@"hex %@", colorSwatch.hexString];
  self.rgbLabel.text = [NSString stringWithFormat:@"rgb %@", colorSwatch.rgbString];
  self.cmykLabel.text = [NSString stringWithFormat:@"cmyk %@", colorSwatch.cmykString];
  self.labLabel.text = [NSString stringWithFormat:@"lab %@", colorSwatch.cielabString];
  self.hsbLabel.text = [NSString stringWithFormat:@"hsb %@", colorSwatch.hsbString];
  
  // Update the suggested palette colours
  if(colorSwatch.relatedColors.count == self.swatchTiles.count) {
    [colorSwatch.relatedColors enumerateObjectsUsingBlock:^(UIColor *newColor, NSUInteger idx, BOOL *stop) {
      [self.swatchTiles[idx] setBackgroundColor:newColor];
    }];
  }
  
  // And set the appropriate colors for the text
  [self.allLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
    label.textColor = [colorSwatch.color blackOrWhiteContrastingColor];
  }];
  
}

#pragma mark - <RWColorSwatchSelectionDelegate>
- (void)didSelectColorSwatch:(RWTColorSwatch *)swatch sender:(id)sender {
  // Update our swatch property
  self.colorSwatch = swatch;
}

@end
