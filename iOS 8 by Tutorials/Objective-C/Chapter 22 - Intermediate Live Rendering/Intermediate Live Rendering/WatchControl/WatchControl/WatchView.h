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

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface WatchView : UIView

//Toggles
@property (nonatomic, assign) IBInspectable BOOL enableAnalogDesign;
@property (nonatomic, assign) IBInspectable BOOL enableClockSecondHand;
@property (nonatomic, assign) IBInspectable BOOL enableColorBackground;

//Watch Control Hands
@property (nonatomic, strong) CAShapeLayer *ringLayer;
@property (nonatomic, assign) IBInspectable CGFloat ringThickness;
@property (nonatomic, strong) IBInspectable UIColor *ringColor;
@property (nonatomic, assign) IBInspectable CGFloat ringProgress;

//TODO: adjust second hand width, length, position, color
@property (nonatomic, strong) CAShapeLayer *hourHandLayer;
@property (nonatomic, strong) IBInspectable UIColor *hourHandColor;

//TODO: adjust second hand width, length, position, color
@property (nonatomic, strong) CAShapeLayer *minuteHandLayer;
@property (nonatomic, strong) IBInspectable UIColor *minuteHandColor;

//Represents the first half of the watch.
@property (nonatomic, strong) CAShapeLayer *secondHandLayer;
@property (nonatomic, strong) IBInspectable UIColor *secondHandColor;


//Base Layer items. (Background, image background)
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) IBInspectable UIColor *backgroundLayerColor;

@property (nonatomic, strong) CAShapeLayer *backgroundImageLayer;
@property (nonatomic, strong) IBInspectable UIImage *backgroundImage;

@property (nonatomic, assign) IBInspectable CGFloat lineWidth;
@property (nonatomic, strong) NSString *currentTimeZone;

//Digital Clock Components
@property (nonatomic, strong) CATextLayer *hourMinuteSecondLayer;
@property (nonatomic, strong) CATextLayer *ampmLayer;
@property (nonatomic, strong) CATextLayer *weekdayLayer;

- (void)startTimeWithTimeZone:(NSString *)string;
- (void)endTime;
- (void)copyClockSettingsWithWatchView:(WatchView *)clock;



@end
