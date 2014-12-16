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

@import UIKit;
@import UIWidgets;
#import "Establishment.h"

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) Establishment* detailItem;

@property (weak, nonatomic) IBOutlet UIImageView* coverView;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet StarRatingControl* starRating;
@property (weak, nonatomic) IBOutlet CheckedButton* kidsMenuButton;
@property (weak, nonatomic) IBOutlet CheckedButton* healthyChoiceButton;
@property (weak, nonatomic) IBOutlet UIButton* womensRoomButton;
@property (weak, nonatomic) IBOutlet UIButton* mensRoomButton;
@property (weak, nonatomic) IBOutlet UIButton* boosterButton;
@property (weak, nonatomic) IBOutlet UIButton* highchairButton;
@property (weak, nonatomic) IBOutlet UIButton* addPhotoButton;
@property (weak, nonatomic) IBOutlet UIScrollView* photoScrollView;
@property (weak, nonatomic) IBOutlet UITextView* noteTextView;

@end

