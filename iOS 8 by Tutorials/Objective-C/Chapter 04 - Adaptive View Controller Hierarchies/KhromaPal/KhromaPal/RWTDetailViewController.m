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

#import "RWTDetailViewController.h"
#import "Colours.h"
#import "RWTPaletteContainer.h"

@interface RWTDetailViewController () <RWTPaletteDisplayContainer>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;

@end



@implementation RWTDetailViewController

#pragma mark - Managing the detail item
- (void)setColorPalette:(RWTColorPalette *)colorPalette {
  if(_colorPalette != colorPalette) {
    _colorPalette = colorPalette;
    
    // Update the view
    [self configureView];
    
    if (self.masterPopoverController != nil) {
      [self.masterPopoverController dismissPopoverAnimated:YES];
    }
  }
}

- (void)configureView {
  // Update the user interface for the detail item.
  
  if (self.colorPalette) {
    // Ensure that all the content is visible
    [self makeAllContentHidden:NO];
    
    // Update the color panels
    if(self.colorLabelCollection.count == self.colorPalette.colors.count) {
      [self.colorPalette.colors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
        UILabel *colorLabel = self.colorLabelCollection[idx];
        colorLabel.backgroundColor = color;
        colorLabel.text = [color hexString];
        colorLabel.textColor = [[color blackOrWhiteContrastingColor] colorWithAlphaComponent:0.6];
      }];
    }
    // And the title label
    self.title = self.colorPalette.name;
    self.titleLabel.text = self.colorPalette.name;
    
    // Central color
    NSUInteger middleIndex = floor((self.colorPalette.colors.count - 1) / 2);
    UIColor *middleColor = self.colorPalette.colors[middleIndex];
    
    // Color the title label text
    self.titleLabel.textColor = [[middleColor blackOrWhiteContrastingColor] colorWithAlphaComponent:0.6];
  } else {
    // Rather than just appear blank, let's display an empty view controller    
    UIViewController *empty = [self.storyboard instantiateViewControllerWithIdentifier:@"NoPaletteSelectedVC"];
    [self showViewController:empty sender:self];
    
    [self makeAllContentHidden:YES];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  if(self.splitViewController && !self.splitViewController.collapsed) {
    [self.navigationItem setLeftBarButtonItem:[self.splitViewController displayModeButtonItem] animated:YES];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.hidesBackButton = NO;
  }
}

#pragma mark - <RWTPaletteDisplayContainer>
- (RWTColorPalette *)rw_currentlyDisplayedPalette
{
  return self.colorPalette;
}

#pragma mark - Utilities
- (void)makeAllContentHidden:(BOOL)hidden {
  [self.view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
    subview.hidden = hidden;
  }];
  if(hidden) {
    self.title = @"";
  }
}

@end
