//
//  StarRatingView.h
//  BabiFüd
//
//  Created by Michael Katz on 6/29/14.
//  Copyright (c) 2014 MikeKatz. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface StarRatingView : UIView

@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) IBInspectable float rating;

@end
