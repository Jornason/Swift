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

#import "RWTProgressNavigationController.h"

@implementation RWTProgressNavigationController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
  self.progressView.hidden = YES;
  [self.view addSubview:self.progressView];
  
  NSArray *verticalConstraints = [NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:[navigationBar]-[progressView(2@20)]"
                                  options:NSLayoutFormatDirectionLeadingToTrailing
                                  metrics:nil
                                  views:@{@"progressView": self.progressView, @"navigationBar": self.navigationBar}];
  
  NSArray *horizontalConstraints = [NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|[progressView]|"
                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                    metrics:nil
                                    views:@{@"progressView": self.progressView}];
  
  [self.view addConstraints:verticalConstraints];
  [self.view addConstraints:horizontalConstraints];
  
  [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.progressView setProgress:0 animated:NO];
  
}

@end
