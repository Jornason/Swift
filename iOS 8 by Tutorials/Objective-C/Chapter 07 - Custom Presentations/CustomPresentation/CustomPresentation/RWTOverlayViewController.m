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

#import "RWTOverlayViewController.h"

@interface RWTOverlayViewController ()

@property (strong, nonatomic) UIView *contentContainerView;
@property (strong, nonatomic) UILabel *countryNameLabel;
@property (strong, nonatomic) UILabel *languageLabel;
@property (strong, nonatomic) UILabel *populationLabel;
@property (strong, nonatomic) UILabel *currencyLabel;
@property (strong, nonatomic) UILabel *factsLabel;
@property (strong, nonatomic) UIButton *closeButton;

@property (strong, nonatomic) RWTCountry *country;

@end

@implementation RWTOverlayViewController

- (instancetype)initWithCountry:(RWTCountry *)country {
  self = [super init];
  if (self) {
    _country = country;
    
    [self setModalPresentationStyle:UIModalPresentationCustom];
    [self configureUIElements];
  }
  
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.countryNameLabel.text = self.country.countryName;
  self.languageLabel.text = [NSString stringWithFormat:@"Language: %@", self.country.language];
  self.populationLabel.text = [NSString stringWithFormat:@"Population: %@", self.country.population];
  self.currencyLabel.text = [NSString stringWithFormat:@"Currency: %@", self.country.currency];
  self.factsLabel.text = [NSString stringWithFormat:@"Fact: \n%@", self.country.fact];
}

- (void)configureUIElements {
  self.view.backgroundColor = [UIColor clearColor];
  
  self.contentContainerView = [[UIView alloc] init];
  self.contentContainerView.translatesAutoresizingMaskIntoConstraints = NO;
  self.contentContainerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
  self.contentContainerView.layer.cornerRadius = 5.0;
  [self.view addSubview:self.contentContainerView];
  
  CGFloat titleFontSize = 24.0;
  CGFloat labelFontSize = 10.0;
  NSNumber *horizontalSpacing = @(10);
  NSNumber *containerHeight = @(160);
  NSNumber *containerTopSpacing = @(5);
  NSNumber *containerBottomSpacing = @(5);
  NSNumber *itemSpacing = @(5);
  NSNumber *maxSpacing = @(5);
  
  if (self.view.bounds.size.width > 568.0) {
    titleFontSize = 42.0;
    labelFontSize = 18.0;
    horizontalSpacing = @(60);
    containerHeight = @(350);
    containerTopSpacing = @(20);
    containerBottomSpacing = @(60);
    itemSpacing = @(20);
    maxSpacing = @(200);
  }
  
  
  self.countryNameLabel = [[UILabel alloc] init];
  [self addToViewAndapplyStylingAndFontSize:titleFontSize toLabel:self.countryNameLabel];
  
  self.languageLabel = [[UILabel alloc] init];
  [self addToViewAndapplyStylingAndFontSize:labelFontSize toLabel:self.languageLabel];
  
  self.populationLabel = [[UILabel alloc] init];
  [self addToViewAndapplyStylingAndFontSize:labelFontSize toLabel:self.populationLabel];
  
  self.currencyLabel = [[UILabel alloc] init];
  [self addToViewAndapplyStylingAndFontSize:labelFontSize toLabel:self.currencyLabel];
  
  self.factsLabel = [[UILabel alloc] init];
  self.factsLabel.numberOfLines = 0;
  [self addToViewAndapplyStylingAndFontSize:labelFontSize toLabel:self.factsLabel];
  
  
  self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.closeButton.tintColor = [UIColor whiteColor];
  self.closeButton.titleLabel.font = [UIFont systemFontOfSize:labelFontSize];
  [self.closeButton setTitle:@"Close" forState:UIControlStateNormal];
  [self.closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [self.contentContainerView addSubview:self.closeButton];
  
  
  NSDictionary *views = @{@"contentContainerView": self.contentContainerView,
                          @"countryNameLabel": self.countryNameLabel,
                          @"languageLabel": self.languageLabel,
                          @"populationLabel": self.populationLabel,
                          @"currencyLabel": self.currencyLabel,
                          @"factsLabel": self.factsLabel,
                          @"closeButton": self.closeButton};
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[contentContainerView]-(spacing)-|"
                                                                    options:0 metrics:@{@"spacing": horizontalSpacing}
                                                                      views:views]];
  
  [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[countryNameLabel]-|" options:0 metrics:nil views:views]];
  [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[languageLabel]-|" options:0 metrics:nil views:views]];
  [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[populationLabel]-|" options:0 metrics:nil views:views]];
  [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[currencyLabel]-|" options:0 metrics:nil views:views]];
  [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[closeButton]-|" options:0 metrics:nil views:views]];
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=containerTopSpacing)-[contentContainerView(containerHeight)]-(containerBottomSpacing)-|"
                                                                    options:0
                                                                    metrics:@{@"containerHeight": containerHeight,
                                                                              @"containerTopSpacing": containerTopSpacing,
                                                                              @"containerBottomSpacing": containerBottomSpacing}
                                                                      views:views]];
  
  [self.contentContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(itemSpacing)-[countryNameLabel]-(itemSpacing)-[languageLabel]-(itemSpacing)-[populationLabel]-(itemSpacing)-[currencyLabel]-(<=maxSpacing)-[closeButton]-(itemSpacing)-|"
                                                                                    options:0
                                                                                    metrics:@{@"itemSpacing": itemSpacing,
                                                                                              @"maxSpacing": maxSpacing}
                                                                                      views:views]];
  
  [self.contentContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.factsLabel
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.languageLabel
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:0]];
  
  [self.contentContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.factsLabel
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentContainerView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0]];
  
  [self.contentContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.factsLabel
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentContainerView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1.0
                                                                         constant:0]];
}

- (void)addToViewAndapplyStylingAndFontSize:(CGFloat)fontSize toLabel:(UILabel *)label {
  label.translatesAutoresizingMaskIntoConstraints = NO;
  label.backgroundColor = [UIColor clearColor];
  label.font = [UIFont boldSystemFontOfSize:fontSize];
  label.textColor = [UIColor whiteColor];
  
  [self.contentContainerView addSubview:label];
}

- (void)closeButtonPressed:(UIButton *)sender {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
