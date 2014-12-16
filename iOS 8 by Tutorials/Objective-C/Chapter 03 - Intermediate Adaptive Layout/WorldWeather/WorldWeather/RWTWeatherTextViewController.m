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

#import "RWTWeatherTextViewController.h"
#import "RWTDailyWeatherCollectionViewController.h"

@interface RWTWeatherTextViewController ()

@end

@implementation RWTWeatherTextViewController

- (void)setCityWeather:(RWTCityWeather *)cityWeather
{
  if (cityWeather != _cityWeather) {
    _cityWeather = cityWeather;
    if(self.view) {
      [self configureView];
    }
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self configureView];
  
  // The collection view is always compact height
  for (UIViewController *vc in self.childViewControllers) {
    [self setOverrideTraitCollection:[UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact] forChildViewController:vc];
  }
}

- (void)configureView {
  // Update the user interface for the detail item.
  if (self.cityWeather) {
    [self setContentAsHidden:NO];
    self.cityNameLabel.text = self.cityWeather.name;
    
    RWTDailyWeather *todaysWeather = self.cityWeather.weather.firstObject;
    RWTWeatherStatus *todaysStatus = todaysWeather.status;
    self.temperatureLabel.text = [NSString stringWithFormat:@"%ldC", (long)todaysStatus.temperature.integerValue];
    [self provideDataToContainedViewControllers];
  } else {
    [self setContentAsHidden:YES];
  }
}

- (void)setContentAsHidden:(BOOL)hidden {
  NSArray *content = @[self.cityNameLabel, self.temperatureLabel];
  for (UIView *contentView in content) {
    contentView.hidden = hidden;
  }
}


- (void)provideDataToContainedViewControllers {
  for (UIViewController *vc in self.childViewControllers) {
    if([vc respondsToSelector:@selector(setDailyWeather:)]) {
      [((id)vc) setDailyWeather:self.cityWeather.weather];
    }
  }
}

@end
