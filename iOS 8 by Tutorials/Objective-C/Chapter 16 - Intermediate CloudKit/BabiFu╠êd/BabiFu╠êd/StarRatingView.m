//
//  StarRatingView.m
//  BabiFüd
//
//  Created by Michael Katz on 6/29/14.
//  Copyright (c) 2014 MikeKatz. All rights reserved.
//

#import "StarRatingView.h"

@implementation StarRatingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit
{
    self.opaque = NO;
    self.insets = UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Drawing code
    CGRect drawArea = UIEdgeInsetsInsetRect(rect, self.insets);
    
    CGFloat starHeight = drawArea.size.height;
    CGFloat spacing = starHeight / 2.;//floorf((drawArea.size.width - 5.0 * starHeight) / 4.0);
    [[UIColor whiteColor] setStroke];
    [[UIColor whiteColor] setFill];

    
    for (int i = 0; i < 5; i++) {
        CGFloat x = self.insets.left + starHeight * i + spacing * i;
        CGFloat y = self.insets.top;
        
        UIBezierPath* path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(x + starHeight / 2., y)];
        [path addLineToPoint:CGPointMake(x+ 3. / 4. * starHeight, y + starHeight / 3.)];
        [path addLineToPoint:CGPointMake(x + starHeight, y + starHeight / 3.)];
        [path addLineToPoint:CGPointMake(x+ 3. / 4. * starHeight, y + starHeight * 2. / 3.)];
        [path addLineToPoint:CGPointMake(x + starHeight, y + starHeight)];
        [path addLineToPoint:CGPointMake(x + starHeight / 2., y + starHeight * 3. / 4.)];
        [path addLineToPoint:CGPointMake(x , y + starHeight)];
        [path addLineToPoint:CGPointMake(x + starHeight / 3., y + starHeight * 2. / 3.)];
        [path addLineToPoint:CGPointMake(x , y + starHeight / 3.)];
        [path addLineToPoint:CGPointMake(x + starHeight / 3., y + starHeight / 3.)];
        [path closePath];
       
        
        [path stroke];
        
        if (self.rating >= i+1) {
            [path fill];
        }
    }
}


@end
