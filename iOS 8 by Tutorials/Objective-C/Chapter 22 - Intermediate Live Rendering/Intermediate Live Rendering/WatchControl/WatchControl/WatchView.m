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

#import "WatchView.h"

@interface WatchView()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation WatchView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void) commonInit
{
	//Initialize here.
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self createClockFace];
}

- (void)updateLayerProperties {
	if (self.ringProgress == 0) {
		self.ringLayer.strokeEnd = self.ringProgress / 60.0;
	}
	
	if (self.backgroundImageLayer) {
		if (self.backgroundImage)
		{
			self.backgroundImageLayer.contents = (id)self.backgroundImage.CGImage;
		}
	}
	
	if (self.backgroundLayer) {
		self.backgroundLayer.fillColor = self.backgroundLayerColor.CGColor;
	}
	
	if (self.enableAnalogDesign) {
		[self setHideAnalogDesign:NO];
		[self setHideDigitalDesign:YES];
		
		if (self.enableClockSecondHand) {
			[self setHideSecondClockHand:NO];
			[self setHideRingLayer:YES];
		} else if (!self.enableClockSecondHand) {
			[self setHideSecondClockHand:YES];
			[self setHideRingLayer:NO];
		} else {
			[self setHideRingLayer:YES];
			[self setHideSecondClockHand:YES];
		}
	} else {
		[self setHideDigitalDesign:NO];
		[self setHideAnalogDesign:YES];
	}
	
	if (self.enableColorBackground) {
		[self setHideImageBackground:YES];
	} else {
		[self setHideImageBackground:NO];
	}
}

#pragma mark Methods to create Clock Face
- (void)createClockFace
{
	[self layoutBackgroundLayer];
	[self layoutBackgroundImageLayer];
	
	if (self.enableAnalogDesign) {
		[self createAnalogClock];
	} else {
		[self createDigitalClock];
	}
	
	[self updateLayerProperties];
}

- (void)createAnalogClock
{
	[self layoutMinuteHandLayer];
	[self layoutHourHandLayer];
	
	if (self.enableClockSecondHand) {
		[self layoutSecondHandLayer];
	} else {
		[self layoutWatchRingLayer];
	}
}

- (void)createDigitalClock
{
	[self layoutHourMinuteSecondText];
	[self layoutAmPmText];
	[self layoutWeekDayText];
}

#pragma mark - Creating Base Layers
- (void)layoutBackgroundLayer
{
	if (!self.backgroundLayer)
	{
		self.backgroundLayer = [CAShapeLayer layer];
		[self.layer addSublayer:self.backgroundLayer];
		CGRect insetBounds = CGRectInset(self.bounds, self.lineWidth / 2.0, self.lineWidth / 2.0);
		UIBezierPath *innerPath = [UIBezierPath bezierPathWithOvalInRect:insetBounds];
		self.backgroundLayer.path = innerPath.CGPath;
		self.backgroundLayer.fillColor = self.backgroundLayerColor.CGColor;
		self.backgroundLayer.lineWidth = self.lineWidth;
		self.backgroundLayer.strokeColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
	}
	self.backgroundLayer.frame = self.bounds;
}

- (void)layoutWatchRingLayer
{
	if (!self.ringLayer) {
		self.ringLayer = [CAShapeLayer layer];
		[self.layer addSublayer:self.ringLayer];
		CGRect rect = CGRectInset(self.bounds, self.ringThickness / 2.0, self.ringThickness / 2.0);
		UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
		self.ringLayer.transform = CATransform3DMakeRotation(-(M_PI / 2), 0, 0, 1);
		self.ringLayer.strokeColor = self.ringColor.CGColor;
		self.ringLayer.path = path.CGPath;
		self.ringLayer.fillColor = nil;
		self.ringLayer.lineWidth = self.ringThickness;
	}
	self.ringLayer.frame = self.layer.bounds;
}

- (void)layoutBackgroundImageLayer
{
	if (!self.backgroundImageLayer)
	{
		CAShapeLayer *maskLayer = [CAShapeLayer layer];
		CGRect insetBounds = CGRectInset(self.bounds, self.lineWidth + 3.0, self.lineWidth + 3.0);
		UIBezierPath *innerPath = [UIBezierPath bezierPathWithOvalInRect:insetBounds];
		maskLayer.path = innerPath.CGPath;
		maskLayer.fillColor = [[UIColor blackColor] CGColor];
		maskLayer.frame = self.bounds;
		[self.layer addSublayer:maskLayer];
		
		self.backgroundImageLayer = [CAShapeLayer layer];
		[self.layer addSublayer:self.backgroundImageLayer];
		self.backgroundImageLayer.frame = self.bounds;
		self.backgroundImageLayer.contentsGravity = kCAGravityResizeAspectFill;
		self.backgroundImageLayer.mask = maskLayer;
	}
}

#pragma mark - Creating the different clock hands
- (void)layoutSecondHandLayer
{
	if (!self.secondHandLayer) {
		self.secondHandLayer = [self createClockHandWithAnchorPoint:CGPointMake(1.0, 1.0) withHandLength:20.0 withHandWidth:4.0 withHandAlpha:1.0 withHandColor:self.secondHandColor];
		[self.layer addSublayer:self.secondHandLayer];
	}
}

- (void)layoutMinuteHandLayer
{
	if (!self.minuteHandLayer) {
		self.minuteHandLayer = [self createClockHandWithAnchorPoint:CGPointMake(1.0, 1.0) withHandLength:26.0 withHandWidth:12.0 withHandAlpha:1.0 withHandColor:self.minuteHandColor];
		[self.layer addSublayer:self.minuteHandLayer];
	}
}

- (void)layoutHourHandLayer
{
	if (!self.hourHandLayer) {
		self.hourHandLayer = [self createClockHandWithAnchorPoint:CGPointMake(1.0, 1.0) withHandLength:65.0 withHandWidth:12.0 withHandAlpha:1.0 withHandColor:self.hourHandColor];
		[self.layer addSublayer:self.hourHandLayer];
	}
}

- (void)layoutHourMinuteSecondText
{
	if (!self.hourMinuteSecondLayer) {
		self.hourMinuteSecondLayer = [self createTextLayerWithString:@"00:00:00" withFont:self.bounds.size.height/8.5 withOffset:self.bounds.size.height/2];
		[self.layer addSublayer:self.hourMinuteSecondLayer];
	}
}

- (void)layoutAmPmText
{
	if (!self.ampmLayer) {
		self.ampmLayer = [self createTextLayerWithString:@"am" withFont:self.bounds.size.height/13.0 withOffset:self.bounds.size.height/1.6];
		[self.layer addSublayer:self.ampmLayer];
	}
}

- (void)layoutWeekDayText
{
	if (!self.weekdayLayer) {
		self.weekdayLayer = [self createTextLayerWithString:@"Thursday" withFont:self.bounds.size.height/13.0 withOffset:self.bounds.size.height];
		[self.layer addSublayer:self.weekdayLayer];
	}
}

#pragma mark - Methods for hidding various CALayer components
- (void)setHideImageBackground:(BOOL)willHide
{
	if (self.backgroundImageLayer) {
		self.backgroundImageLayer.hidden = willHide;
	}
}

- (void)setHideSecondClockHand:(BOOL)willHide
{
	if (self.secondHandLayer) {
		self.secondHandLayer.hidden = willHide;
	}
}

- (void)setHideRingLayer:(BOOL)willHide
{
	if (self.ringLayer) {
		self.ringLayer.hidden = willHide;
	}
}

- (void)setHideAnalogDesign:(BOOL)willHide
{
	if (self.secondHandLayer) {
		self.secondHandLayer.hidden = willHide;
	}
	if (self.hourHandLayer) {
		self.hourHandLayer.hidden = willHide;
	}
	if (self.minuteHandLayer) {
		self.minuteHandLayer.hidden = willHide;
	}
	if (self.ringLayer) {
		self.ringLayer.hidden = willHide;
	}
}

- (void)setHideDigitalDesign:(BOOL)willHide
{
	if (self.hourMinuteSecondLayer) {
		self.hourMinuteSecondLayer.hidden = willHide;
	}
	if (self.ampmLayer) {
		self.ampmLayer.hidden = willHide;
	}
	if (self.weekdayLayer) {
		self.weekdayLayer.hidden = willHide;
	}
}

#pragma mark - Helper Methods to create CAShapeLayers, and CATextLayers
//Create clock hands of various sizes, alpha, color, anchor point etc.
- (CAShapeLayer *)createClockHandWithAnchorPoint:(CGPoint)anchorPoint withHandLength:(CGFloat)handLength withHandWidth: (CGFloat)handWidth withHandAlpha:(CGFloat)handAlpha withHandColor:(UIColor *)handColor
{
	CAShapeLayer *handLayer = [CAShapeLayer layer];
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(1.0, handLength)];
	[path addLineToPoint:CGPointMake(1.0, (self.bounds.size.height / 2.0))];
	
	handLayer.bounds = CGRectMake(0.0, 0.0, 1.0, self.bounds.size.height / 2.0);
	handLayer.anchorPoint = anchorPoint;
	handLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	handLayer.lineWidth = handWidth;
	handLayer.opacity = handAlpha;
	handLayer.strokeColor = handColor.CGColor;
	handLayer.path = path.CGPath;
	handLayer.lineCap = kCALineCapRound;
	return handLayer;
}

//Create and returns a CATextLayer with a specific font and offset
- (CATextLayer *)createTextLayerWithString:(NSString *)string withFont: (CGFloat)fontSize withOffset: (CGFloat)offset
{
	
	CATextLayer *layer = [[CATextLayer alloc] init];
	[layer setFont:@"HelveticaNeue-Light"];
	[layer setFontSize:fontSize];
	[layer setFrame:CGRectMake(0.0, 0.0, self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)];
	layer.position = CGPointMake(CGRectGetMidX(self.bounds), offset);
	[layer setString:string];
	[layer setAlignmentMode:kCAAlignmentCenter];
	[layer setForegroundColor:[[UIColor whiteColor] CGColor]];
	[layer setContentsScale:[[UIScreen mainScreen] scale]];
	
	return layer;
}

#pragma mark - Methods to start the clock ticking
- (void)startTimeWithTimeZone:(NSString *)string
{
	[self endTime];
	//Set the current time zone user has selected.
	self.currentTimeZone = string;
	
	if (self.enableAnalogDesign)
	{
		self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animateAnalogClock) userInfo:nil repeats:YES];
	}
	else
	{
		self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animateDigitalClock) userInfo:nil repeats:YES];
	}
}

- (void)endTime
{
	[self.timer invalidate];
	self.timer = nil;
}

- (void)animateAnalogClock
{
	//Get today's time.
	NSDate *now = [NSDate date];
	
	//Create a date formatter, and set the time zone selected by the user.
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:self.currentTimeZone]];
	[dateFormatter setDateFormat:@"hh:mm:ss"];
	
	//Extract the hour, minute, and second from the date string.
	NSArray *dateComponents = [self grabDateComponentsWithString:[dateFormatter stringFromDate:now]];
	
	//Convert string to integers
	NSInteger hours = [dateComponents[0] integerValue];
	NSInteger minutes = [dateComponents[1] integerValue];
	NSInteger seconds = [dateComponents[2] integerValue];
	
	NSInteger minutesIntoDay = hours * 60 + minutes;
	float percentageMinutesIntoDay = minutesIntoDay / (12.0 * 60.0);
	float percentageMinutesIntoHour = (float)minutes / 60.0;
	float percentageSecondsIntoMinute = (float)seconds / 60.0;
	
	//rotates the second hand, if second hand is enabled.
	if (self.enableClockSecondHand)
	{
		self.secondHandLayer.transform = CATransform3DMakeRotation((M_PI * 2) * percentageSecondsIntoMinute, 0, 0, 1);
	}
	else
	{
		self.ringLayer.strokeEnd = seconds / 60.0;
	}
	
	if (self.minuteHandLayer) {
		self.minuteHandLayer.transform = CATransform3DMakeRotation((M_PI * 2) * percentageMinutesIntoHour, 0, 0, 1);
	}
	
	if (self.hourHandLayer) {
		self.hourHandLayer.transform = CATransform3DMakeRotation((M_PI * 2) * percentageMinutesIntoDay, 0, 0, 1);
	}
}

- (void)animateDigitalClock
{
	//Get today's time.
	NSDate *now = [NSDate date];
	
	//Create a date formatter, and set the time zone selected by the user.
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:self.currentTimeZone]];
	[dateFormatter setDateFormat:@"hh:mm:ss:a:EEEE"];
	
	//Extract the hour, minute, and second from the date string.
	NSArray *dateComponents = [self grabDateComponentsWithString:[dateFormatter stringFromDate:now]];
	
	//Convert string to integers
	NSInteger hours = [dateComponents[0] integerValue];
	NSInteger minutes = [dateComponents[1] integerValue];
	NSInteger seconds = [dateComponents[2] integerValue];
	NSString *ampm = [dateComponents[3] lowercaseString];
	NSString *weekday = dateComponents[4];
	
	NSString *hourminutesecondString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
	if (self.hourMinuteSecondLayer) {
		[self.hourMinuteSecondLayer setString:hourminutesecondString];
	}
	if (self.ampmLayer) {
		[self.ampmLayer setString:ampm];
	}
	
	if (self.weekdayLayer) {
		[self.weekdayLayer setString:weekday];
	}
}

#pragma mark - Copying Setting

- (void)copyClockSettingsWithWatchView:(WatchView *)clock
{
	self.enableAnalogDesign = clock.enableAnalogDesign;
	self.enableClockSecondHand = clock.enableClockSecondHand;
	self.enableColorBackground = clock.enableColorBackground;
	
	self.ringThickness = clock.ringThickness;
	self.ringColor = clock.ringColor;
	self.ringProgress = clock.ringProgress;
	self.hourHandColor = clock.hourHandColor;
	self.minuteHandColor = clock.minuteHandColor;
	self.secondHandColor = clock.secondHandColor;
	self.backgroundImage = clock.backgroundImage;
	self.lineWidth = clock.lineWidth;
	self.backgroundLayerColor = clock.backgroundLayerColor;
	self.currentTimeZone = clock.currentTimeZone;
}

#pragma mark - Utilities
//Had some problems getting the actual time from a time zone, so i'm manually stripping out the hour, minute, and seconds. NSDate was outputting the wrong thing/
//array[0] = hour, //array[1] = minute, // array[2] = seconds
- (NSArray *) grabDateComponentsWithString: (NSString *)dateString
{
	NSArray *dateArray = [dateString componentsSeparatedByString:@":"];
	return dateArray;
}

@end
