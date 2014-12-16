//  KeyboardViewController.m

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

#import "KeyboardViewController.h"

#import "KeyboardThemeData.h"
#import "RWTLocationManager.h"

static int const kTagForSpecialButtons = 99;

static float const kScaleSizeOnTap = 2.5f;
static float const kScaleSpeedOnTap = 0.10f;

static bool const kShiftAutoOff = YES;

@interface KeyboardViewController () {
  NSMutableArray *_appData;
  int _currentThemeID;
  
  BOOL _shiftOn;
  
  CLLocation *_currentLocation;
}

@property (strong, nonatomic) UIView *containerView;

@property (strong, nonatomic) IBOutlet UIView *background;
@property (strong, nonatomic) IBOutlet UIView *rowCustom;
@property (strong, nonatomic) IBOutlet UIView *row1;
@property (strong, nonatomic) IBOutlet UIView *row2;
@property (strong, nonatomic) IBOutlet UIView *row3;
@property (strong, nonatomic) IBOutlet UIView *row4;

@property (strong, nonatomic) IBOutlet UIView *rowCustomAlt1;
@property (strong, nonatomic) IBOutlet UIView *rowCustomAlt2;
@property (strong, nonatomic) IBOutlet UIView *rowCustomAlt3;
@property (strong, nonatomic) IBOutlet UIView *rowCustomAlt4;

@property (strong, nonatomic) IBOutlet UIButton *btnTheme1;
@property (strong, nonatomic) IBOutlet UIButton *btnTheme2;
@property (strong, nonatomic) IBOutlet UIButton *btnTheme3;
@property (strong, nonatomic) IBOutlet UIButton *btnTheme4;

@property (strong, nonatomic) IBOutlet UIButton *btnLocation;

@end

@implementation KeyboardViewController

#pragma mark - Init View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
  }
  return self;
}

#pragma mark - View Appear / Disappear

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  /* Notifications are not required */
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  /* Remove the Notification, if added */
  [[NSNotificationCenter defaultCenter] removeObserver:NSUserDefaultsDidChangeNotification];
}

#pragma mark - View Load / Unload

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // use the xib for the main view
  self.containerView = [[[NSBundle mainBundle] loadNibNamed:@"KeyboardView" owner:self options:nil] objectAtIndex:0];
  self.view = self.containerView;
  
  [self configureGesturesForView:self.rowCustomAlt1];
  [self configureGesturesForView:self.rowCustomAlt2];
  [self configureGesturesForView:self.rowCustomAlt3];
  [self configureGesturesForView:self.rowCustomAlt4];
  
  _appData = [NSMutableArray arrayWithArray:[KeyboardThemeData configureThemeData]];
  
  [self getCurrentAppSettings];
  [self configureCoreLocationManager];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Style Keyboard for Selected Theme

- (void)defaultsDidChange:(NSNotification *)notification {
  [self getCurrentAppSettings];
}

- (void)getCurrentAppSettings {
  int currentThemeID = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kThemePreference];
  [self styleKeyboardWithThemeID:currentThemeID];
}

- (void)styleThemeButton:(UIButton *)button withTheme:(KeyboardThemeData *)theme {
  UIImage *image = [[UIImage imageNamed:@"whiteLine"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  button.selected = NO;
  [button setBackgroundImage:image forState:UIControlStateSelected];
  button.tintColor = theme.colorForButtonFont;
}

- (void)styleKeyboardWithThemeID:(int )themeID {
  KeyboardThemeData *currentTheme = [_appData objectAtIndex:themeID];
  
  /* Reset theme buttons */
  [self styleThemeButton:self.btnTheme1 withTheme:currentTheme];
  [self styleThemeButton:self.btnTheme2 withTheme:currentTheme];
  [self styleThemeButton:self.btnTheme3 withTheme:currentTheme];
  [self styleThemeButton:self.btnTheme4 withTheme:currentTheme];
  
  switch (themeID) {
    case 0:
      self.btnTheme1.selected = YES;
      break;
    case 1:
      self.btnTheme2.selected = YES;
      break;
    case 2:
      self.btnTheme3.selected = YES;
      break;
    case 3:
      self.btnTheme4.selected = YES;
      break;
    default:
      self.btnTheme1.selected = YES;
      break;
  }
  
  /* Handle Tint Color for Location Button */
  UIImage *image = [[UIImage imageNamed:@"pin"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [self.btnLocation setImage:image forState:UIControlStateNormal];
  self.btnLocation.tintColor = currentTheme.colorForButtonFont;
  
  /* Set Colors */
  self.containerView.backgroundColor = currentTheme.colorForBackground;
  
  self.rowCustom.backgroundColor = currentTheme.colorForCustomRow;
  self.row1.backgroundColor = currentTheme.colorForRow1;
  self.row2.backgroundColor = currentTheme.colorForRow2;
  self.row3.backgroundColor = currentTheme.colorForRow3;
  self.row4.backgroundColor = currentTheme.colorForRow4;
  
  self.rowCustomAlt1.backgroundColor = currentTheme.colorForCustomRow;
  self.rowCustomAlt2.backgroundColor = currentTheme.colorForCustomRow;
  self.rowCustomAlt3.backgroundColor = currentTheme.colorForCustomRow;
  self.rowCustomAlt4.backgroundColor = currentTheme.colorForCustomRow;
  
  /* Set Button Case */
  [self setButtonCase];
  
  /* Set Button Fonts */
  [self setButtonFont:self.rowCustom withTheme:currentTheme];
  [self setButtonFont:self.rowCustomAlt1 withTheme:currentTheme];
  [self setButtonFont:self.rowCustomAlt2 withTheme:currentTheme];
  [self setButtonFont:self.rowCustomAlt3 withTheme:currentTheme];
  
  [self setButtonFont:self.row1 withTheme:currentTheme];
  [self setButtonFont:self.row2 withTheme:currentTheme];
  [self setButtonFont:self.row3 withTheme:currentTheme];
  [self setButtonFont:self.row4 withTheme:currentTheme];
}

- (void)setButtonCase {
  [self setShiftStatus:self.row1];
  [self setShiftStatus:self.row2];
  [self setShiftStatus:self.row3];
  [self setShiftStatus:self.row4];
}

- (void)setButtonFont:(UIView *)viewWithButtons withTheme:(KeyboardThemeData *)theme {
  for (UIButton *button in viewWithButtons.subviews) {
    if ([button isKindOfClass:[UIButton class]]) {
      button.titleLabel.font = theme.keyboardButtonFont;
      [button setTitleColor:theme.colorForButtonFont forState:UIControlStateNormal];
      
      if (button.tag == kTagForSpecialButtons) {
        button.titleLabel.font = [UIFont fontWithName:button.titleLabel.font.fontName size:kSpecialButtonFontSize];
      }
    }
  }
}

- (void)setShiftStatus:(UIView *)viewWithButtons {
  for (UIButton *button in viewWithButtons.subviews) {
    if ([button isKindOfClass:[UIButton class]]) {
      if (_shiftOn) {
        if (button.tag != kTagForSpecialButtons) {
          [button setTitle:[button.titleLabel.text uppercaseString] forState:UIControlStateNormal];
        }
      } else {
        [button setTitle:[button.titleLabel.text lowercaseString] forState:UIControlStateNormal];
      }
    }
  }
}

#pragma mark - Button Actions, Standard Keys

- (IBAction)btnAdvanceToNextInputMode_tap:(id)sender {
  [self advanceToNextInputMode];
  
  // calling this method is required; it allows the user to select another keyboard!!!
}

- (IBAction)btnKeyPressed_tap:(id)sender {
  UIButton *button = (UIButton *)sender;
  NSString *buttonText = button.titleLabel.text;
  
  [self animateButtonTapForButton:button];
  
  [self.textDocumentProxy insertText:buttonText];
  
  if (kShiftAutoOff) {
    _shiftOn = NO;
    [self setButtonCase];
  }
}

#pragma mark - Button Actions, Special Keys

- (IBAction)btnShiftKey_tap:(id)sender {  
  if (_shiftOn) {
    _shiftOn = NO;
  } else {
    _shiftOn = YES;
  }
  
  [self setButtonCase];
}

- (IBAction)btnBackspaceKey_tap:(id)sender {
  [self.textDocumentProxy deleteBackward];
}

- (IBAction)btnSpacebarKey_tap:(id)sender {
  [self.textDocumentProxy insertText:@" "];
}

- (IBAction)btnReturnKey_tap:(id)sender {
  [self.textDocumentProxy insertText:@"\n"];
}

- (IBAction)btnChangeTheme_tap:(id)sender {
  UIButton *button = (UIButton *)sender;
  [button setSelected:YES];
  [[NSUserDefaults standardUserDefaults] setInteger:button.tag forKey:kThemePreference];
  [[NSUserDefaults standardUserDefaults] synchronize];
  _currentThemeID = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kThemePreference];
  
  [self styleKeyboardWithThemeID:_currentThemeID];
}

- (IBAction)btnChangeAltRow_tap:(id)sender {
  UIButton *button = (UIButton *)sender;
  
  self.rowCustom.hidden = YES;
  
  self.rowCustomAlt1.hidden = YES;
  self.rowCustomAlt2.hidden = YES;
  self.rowCustomAlt3.hidden = YES;
  self.rowCustomAlt4.hidden = YES;
  
  if ([button.titleLabel.text isEqualToString:@"#1"]) {
    self.rowCustom.hidden = YES;
    self.rowCustomAlt1.hidden = NO;
    [button setTitle:@"#2" forState:UIControlStateNormal];
  } else if ([button.titleLabel.text isEqualToString:@"#2"]) {
    self.rowCustom.hidden = YES;
    self.rowCustomAlt2.hidden = NO;
    [button setTitle:@"#3" forState:UIControlStateNormal];
  } else if ([button.titleLabel.text isEqualToString:@"#3"]) {
    self.rowCustom.hidden = YES;
    self.rowCustomAlt3.hidden = NO;
    [button setTitle:@"#4" forState:UIControlStateNormal];
  } else if ([button.titleLabel.text isEqualToString:@"#4"]) {
    self.rowCustom.hidden = YES;
    self.rowCustomAlt4.hidden = NO;
    [button setTitle:@"#0" forState:UIControlStateNormal];
  }  else if ([button.titleLabel.text isEqualToString:@"#0"]) {
    self.rowCustom.hidden = NO;
    [button setTitle:@"#1" forState:UIControlStateNormal];
  }
}

- (IBAction)btnLocation_tap:(id)sender {
  [self geocodeLocation:_currentLocation];
}

#pragma mark - Location Services

- (void)configureCoreLocationManager {
  self.btnLocation.enabled = NO;
  [[RWTLocationManager sharedLocationManager]setDelegate:self];
  [[RWTLocationManager sharedLocationManager].locationManager requestAlwaysAuthorization];
  [[RWTLocationManager sharedLocationManager].locationManager startUpdatingLocation];
}

- (void)locationManagerDidUpdateLocation:(CLLocation *)location {
  _currentLocation = location;
  self.btnLocation.enabled = YES;
}

- (void)geocodeLocation:(CLLocation*)location {
  NSString *string = [NSString stringWithFormat:@"%.8f, %.8f", location.coordinate.latitude, location.coordinate.longitude];
  [self.textDocumentProxy insertText:string];
}

#pragma mark - Button Animations

- (void)animateButtonTapForButton:(UIButton *)button {
  [UIView animateWithDuration:kScaleSpeedOnTap delay: 0 options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction) animations:^{
    button.transform = CGAffineTransformScale(CGAffineTransformIdentity, kScaleSizeOnTap, kScaleSizeOnTap);
  } completion:^(BOOL finished) {
    button.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
  }];
}

#pragma mark - Swipe Gesture Configuration and Methods

/* This configures the custom row to input numbers 1 - 0 when the user swipes up */

- (void)configureGesturesForView:(UIView *)view {
  for (int i = 0; i <= 9; i++) {
    UIButton *button = (UIButton *)[view viewWithTag:i];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeForNumber:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [button addGestureRecognizer:swipeUp];
  }
}

- (void)swipeForNumber:(UISwipeGestureRecognizer *)gesture {
  NSString *optionalText;
  if ((int)gesture.view.tag == 10)
  {
    optionalText = [NSString stringWithFormat:@"0"];
  }
  else
  {
    optionalText = [NSString stringWithFormat:@"%i", (int)gesture.view.tag];
  }
  
  [self.textDocumentProxy insertText:optionalText];
}

@end