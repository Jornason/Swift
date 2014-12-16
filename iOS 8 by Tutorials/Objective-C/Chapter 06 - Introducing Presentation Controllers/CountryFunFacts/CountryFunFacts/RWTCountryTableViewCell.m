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

#import "RWTCountryTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "RWTCountry.h"

@implementation RWTCountryTableViewCell

- (void)awakeFromNib {
  self.containerView.layer.cornerRadius = 5.0;
  self.containerView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.7].CGColor;
  self.containerView.layer.borderWidth = 1.0;
}

- (void)configureCellForCountry:(RWTCountry *)country {
  self.countryNameLabel.text = country.countryName;
  self.flagImageView.image = [UIImage imageNamed:country.imageName];
}

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  
  self.countryNameLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
}

@end
