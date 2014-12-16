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

#import "RWTMainViewController.h"

#import "RWTBitlyService.h"
#import "RWTBitlyShortenedUrlModel.h"
#import "RWTBitlyHistoryService.h"

@import QuartzCore;

typedef NS_ENUM(NSInteger, RWTMainViewControllerActionButtonState) {
  RWTMainViewControllerActionButtonStateShortenUrl,
  RWTMainViewControllerActionButtonStateCopyUrl
};

@interface RWTMainViewController ()

@property (strong, nonatomic) RWTBitlyService *bitlyService;

@property (weak, nonatomic) IBOutlet UITextField *longUrlTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *domainSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *copiedLabel;

@property (strong, nonatomic) RWTBitlyShortenedUrlModel *shortUrl;
@property (assign, nonatomic) RWTMainViewControllerActionButtonState actionButtonState;

@end

@implementation RWTMainViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (!self) {
    return nil;
  }
  
  _bitlyService = [[RWTBitlyService alloc] initWithOAuthAccessToken:@"235bcd75119549c117bd36945a169af8cac2b660"];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToUIApplicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
  
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.actionButtonState = RWTMainViewControllerActionButtonStateShortenUrl;
  self.actionButton.layer.borderColor = [UIColor whiteColor].CGColor;
  self.actionButton.layer.borderWidth = 1.0/[UIScreen mainScreen].scale;
  self.actionButton.layer.cornerRadius = 15.0;
  self.copiedLabel.hidden = YES;
  
  [self setupLongUrlTextFieldAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:YES animated:animated];
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:NO animated:animated];
  [super viewWillDisappear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    [self setupLongUrlTextFieldAppearance];
  }];
}

- (void)respondToUIApplicationDidBecomeActiveNotification {
  [self resetView];
  [self askToUseClipboardIfUrlPresent];
}

- (void)askToUseClipboardIfUrlPresent {
  NSURL *pasteboardUrl = [UIPasteboard generalPasteboard].URL;
  if (pasteboardUrl) {
    if (![pasteboardUrl.host isEqualToString:@"bit.ly"] &&
        ![pasteboardUrl.host isEqualToString:@"j.mp"] &&
        ![pasteboardUrl.host isEqualToString:@"bitly.com"]) { // don't ask to shorten already shortened urls
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Shorten clipboard item?" message:pasteboardUrl.absoluteString preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self addPasteboardUrlToLongUrlTextField];
        [self dismissViewControllerAnimated:YES completion:nil];
      }];
      
      UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
      }];
      
      [alert addAction:yesAction];
      [alert addAction:noAction];
      
      [self presentViewController:alert animated:YES completion:nil];
    }
  }
}

- (void)addPasteboardUrlToLongUrlTextField {
  NSURL *pasteboardUrl = [UIPasteboard generalPasteboard].URL;
  if (pasteboardUrl) {
    self.longUrlTextField.text = pasteboardUrl.absoluteString;
  }
}

- (IBAction)longUrlTextFieldChanged:(id)sender {
  self.actionButtonState = RWTMainViewControllerActionButtonStateShortenUrl;
  [self.actionButton setTitle:@"Shorten" forState:UIControlStateNormal];
  self.copiedLabel.hidden = YES;
}

- (IBAction)actionButtonPressed:(id)sender {
  switch (self.actionButtonState) {
    case RWTMainViewControllerActionButtonStateShortenUrl:
      [self shortenUrl];
      break;
    case RWTMainViewControllerActionButtonStateCopyUrl:
      [UIPasteboard generalPasteboard].URL = self.shortUrl.shortUrl;
      self.copiedLabel.hidden = NO;
      break;
  }
}

- (void)shortenUrl {
  NSString *domain = nil;
  [self.view endEditing:YES];
  switch (self.domainSegmentedControl.selectedSegmentIndex) {
    case 0:
      domain = @"bit.ly";
      break;
    case 1:
      domain = @"j.mp";
      break;
    case 2:
      domain = @"bitly.com";
      break;
    default:
      domain = @"bit.ly"; // no reason we should hit this case, but default to bit.ly
      break;
  }
  
  NSURL *longUrl = [NSURL URLWithString:self.longUrlTextField.text];
  if (longUrl) {
    [self.bitlyService shortenUrl:longUrl domain:domain completion:^(RWTBitlyShortenedUrlModel *shortUrl, NSError *error)
     {
       dispatch_async(dispatch_get_main_queue(), ^{
         if (error) {
           [self presentError];
         } else {
           self.shortUrl = shortUrl;
           [self.actionButton setTitle:shortUrl.shortUrl.absoluteString forState:UIControlStateNormal];
           self.actionButtonState = RWTMainViewControllerActionButtonStateCopyUrl;
           [[RWTBitlyHistoryService sharedService] addItem:shortUrl];
         }
       });
       
     }];
  } else {
    [self presentError];
  }
}

- (void)presentError {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to Shorten" message:@"Check your entered URL's format and try again." preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    [alert dismissViewControllerAnimated:YES completion:nil];
  }];
  
  [alert addAction:okAction];
  [self presentViewController:alert animated:YES completion:nil];
}


- (void)setupLongUrlTextFieldAppearance {
  NSAttributedString *placeholderString = [[NSAttributedString alloc] initWithString:@"URL"
                                                                          attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
  self.longUrlTextField.attributedPlaceholder = placeholderString;
  CALayer *bottomBorder = [CALayer layer];
  bottomBorder.frame = CGRectMake(0.0f,
                                  self.longUrlTextField.frame.size.height-2,
                                  self.longUrlTextField.frame.size.width,
                                  2.0f);
  bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
  [self.longUrlTextField.layer addSublayer:bottomBorder];
}

- (void)resetView {
  self.longUrlTextField.text = @"";
  self.actionButtonState = RWTMainViewControllerActionButtonStateShortenUrl;
  [self.actionButton setTitle:@"Shorten" forState:UIControlStateNormal];
  self.copiedLabel.hidden = YES;
}

@end
