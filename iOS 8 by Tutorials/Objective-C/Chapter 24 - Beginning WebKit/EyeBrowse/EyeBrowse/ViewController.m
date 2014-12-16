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

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <UITextFieldDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *barBackgroundView;
@property (weak, nonatomic) IBOutlet UITextField *inputURLField;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopReloadButton;

- (IBAction)goBack:(UIBarButtonItem *)sender;
- (IBAction)goForward:(UIBarButtonItem *)sender;
- (IBAction)stopReload:(UIBarButtonItem *)sender;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.barBackgroundView.frame = CGRectMake(0, 0, self.view.frame.size.width, 30); // To fix for iPad
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    self.webView.navigationDelegate = self;
    [self.view insertSubview:self.webView belowSubview:self.progressView];
    
    
    // Constraints
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
    [self.view addConstraint:widthConstraint];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.webView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1
                                                          constant:-44];
    [self.view addConstraint:heightConstraint];
    
    self.inputURLField.text = @"http://www.raywenderlich.com";
    NSURL *URL = [NSURL URLWithString:self.inputURLField.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.progressView setProgress:0.0f animated:NO];
    [self.webView loadRequest:request];

    self.backButton.image = [UIImage imageNamed:@"icon_back"];
    self.forwardButton.image = [UIImage imageNamed:@"icon_forward"];
    self.stopReloadButton.image = [UIImage imageNamed:@"icon_stop"];
    self.backButton.enabled = self.forwardButton.enabled = NO;
    
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqualToString:@"loading"]) {
    
        self.backButton.enabled = self.webView.canGoBack;
        self.forwardButton.enabled = self.webView.canGoForward;
        self.stopReloadButton.image = self.webView.loading ? [UIImage imageNamed:@"icon_stop"] : [UIImage imageNamed:@"icon_refresh"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:self.webView.loading];
        
        if (!self.webView.loading) {
            self.inputURLField.text = self.webView.URL.absoluteString;
        }
        
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
    
        self.progressView.hidden = self.webView.estimatedProgress == 1;
        self.progressView.progress = self.webView.estimatedProgress;
        
    }
    
}

#pragma mark Web view navigation delegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    [self.progressView setProgress:0.0f animated:NO];
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    if (navigationAction.navigationType == WKNavigationTypeLinkActivated && ![navigationAction.request.URL.host.lowercaseString hasPrefix:@"www.raywenderlich.com"]) {
    
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        
    } else {
    
        decisionHandler(WKNavigationActionPolicyAllow);
        
    }
    
}

#pragma mark Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self.inputURLField resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    self.barBackgroundView.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.inputURLField.text]]];
    return NO;
    
}

- (void) cancel {

    [self.inputURLField resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    self.barBackgroundView.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    
}

#pragma mark - Actions

- (IBAction)goBack:(UIBarButtonItem *)sender {
    
    [self.webView goBack];
    
}

- (IBAction)goForward:(UIBarButtonItem *)sender {
    
    [self.webView goForward];
    
}

- (IBAction)stopReload:(UIBarButtonItem *)sender {
    
    if (self.webView.loading) {
    
        [self.webView stopLoading];
        
    } else {
    
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.webView.URL]];
        
    }
    
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    self.barBackgroundView.frame = CGRectMake(0, 0, size.width, 30);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
