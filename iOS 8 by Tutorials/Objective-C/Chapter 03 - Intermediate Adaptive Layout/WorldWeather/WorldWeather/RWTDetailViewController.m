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

@implementation RWTDetailViewController

#pragma mark - VC Lifecycle
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  [self configureView];
  [self configureTraitOverrideForSize:self.view.bounds.size];
  self.navigationItem.hidesBackButton = NO;
  self.navigationItem.leftItemsSupplementBackButton = YES;
}

#pragma mark - Property Overrides
- (void)setCityWeather:(RWTCityWeather *)cityWeather {
  if (cityWeather != _cityWeather) {
    _cityWeather = cityWeather;
    if(self.view) {
      [self configureView];
    }
  }
}


#pragma mark - VC events
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [self configureTraitOverrideForSize:size];
}

#pragma mark - Utility method
- (void)configureTraitOverrideForSize:(CGSize)size {
  UITraitCollection *overrideTraitCollection = nil;
  if(size.height < 1000) {
    overrideTraitCollection = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassCompact];
  }
  // Update child view controllers
  for (UIViewController *vc in self.childViewControllers) {
    [self setOverrideTraitCollection:overrideTraitCollection forChildViewController:vc];
  }
}



#pragma mark - Utility Methods
- (void)configureView {
  // Update the user interface for the detail item.
  if (self.cityWeather) {
    [self setContentAsHidden:NO];
    RWTDailyWeather *todaysWeather = self.cityWeather.weather.firstObject;
    RWTWeatherStatus *todaysStatus = todaysWeather.status;
    self.weatherImageView.image = todaysStatus.statusImage;
    self.title = self.cityWeather.name;
    [self provideDataToContainedViewControllers];
  } else {
    [self setContentAsHidden:YES];
  }
}

- (void)setContentAsHidden:(BOOL)hidden {
  NSArray *content = @[self.weatherImageView];
  for (UIView *contentView in content) {
    contentView.hidden = hidden;
  }
}

- (void)provideDataToContainedViewControllers {
  for (UIViewController *vc in self.childViewControllers) {
    if([vc respondsToSelector:@selector(setCityWeather:)]) {
      [((id)vc) setCityWeather:self.cityWeather];
    }
  }
}

@end
