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


#import "MainViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *priceOnDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation MainViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (!self) {
    return nil;
  }
  
  _dateFormatter = [[NSDateFormatter alloc] init];
  [_dateFormatter setDateFormat:@"EEE M/d"];
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
    
  self.priceOnDayLabel.text = @"";
  self.dayLabel.text = @"";
  
  [self updateWithCurrencyData];
}

- (void)updatePriceOnDayLabel:(RWTBitCoinPrice *)price {
  self.priceOnDayLabel.text = [self.dollarNumberFormatter stringFromNumber:price.value];
}

- (void)updateDayLabel:(RWTBitCoinPrice *)price {
  self.dayLabel.text = [self.dateFormatter stringFromDate:price.time];
}

#pragma mark - JBLineChartViewDataSource & JBLineChartViewDelegate

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex {
  
  RWTBitCoinPrice *selectedPrice = self.prices[horizontalIndex];
  [self updatePriceOnDayLabel:selectedPrice];
  [self updateDayLabel:selectedPrice];
}

- (void)didUnselectLineInLineChartView:(JBLineChartView *)lineChartView {
  self.priceOnDayLabel.text = @"";
  self.dayLabel.text = @"";
}


@end
