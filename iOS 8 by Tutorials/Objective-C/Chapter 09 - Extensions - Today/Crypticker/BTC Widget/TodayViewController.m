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


#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "RWTCurrencyDataViewController.h"


@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UIButton *toggleGraphButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineChartHeightConstraint;

@property (assign, nonatomic) BOOL graphVisible;

@end

@implementation TodayViewController

- (void)awakeFromNib {
  [super awakeFromNib];
  [self setPreferredContentSize:CGSizeMake(0, 70)];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.lineChartHeightConstraint.constant = 0;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self updateWithCurrencyData];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self updatePriceHistoryGraph];
}

- (IBAction)toggleGraph:(id)sender {
  if (self.graphVisible) {
    self.lineChartHeightConstraint.constant = 0;
    self.toggleGraphButton.transform = CGAffineTransformMakeRotation(0);
    [self setPreferredContentSize:CGSizeMake(0, 70.0)];
    self.graphVisible = NO;
  } else {
    self.lineChartHeightConstraint.constant = 98;
    self.toggleGraphButton.transform = CGAffineTransformMakeRotation(180.0 * M_PI/180.0);
    [self setPreferredContentSize:CGSizeMake(0, 180.0)];
    self.graphVisible = YES;
  }
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
  return UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
  // Perform any setup necessary in order to update the view.
  
  // If an error is encoutered, use NCUpdateResultFailed
  // If there's no update required, use NCUpdateResultNoData
  // If there's an update, use NCUpdateResultNewData
  [self updateWithCurrencyData];
  completionHandler(NCUpdateResultNewData);
}

#pragma mark - JBLineChartViewDataSource & JBLineChartViewDelegate

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex {
  return [UIColor colorWithRed:0.17 green:0.49 blue:0.82 alpha:1.0];
}

@end
