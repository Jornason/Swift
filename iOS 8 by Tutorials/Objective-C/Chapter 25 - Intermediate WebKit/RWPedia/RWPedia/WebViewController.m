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

#import "WebViewController.h"
#import "AuthorsTableViewController.h"
#import <WebKit/WebKit.h>

NSString * const AUTHOR_SELECTED = @"authorSelectedNotification";
NSString * const MESSAGE_HANDLER = @"didFetchAuthors";

@interface WebViewController () <WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebView *authorsWebView;
@property (nonatomic, strong) NSArray *authors;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *authorsButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadStopButton;

- (IBAction)authorsButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)goBack:(UIBarButtonItem *)sender;
- (IBAction)goForward:(UIBarButtonItem *)sender;
- (IBAction)reloadStopButtonTapped:(UIBarButtonItem *)sender;

@end

@implementation WebViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.backButton.enabled = self.forwardButton.enabled = self.authorsButton.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authorSelected:)
                                                 name:AUTHOR_SELECTED
                                               object:nil];
    
    // Main webView
    WKWebViewConfiguration *mainWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
    NSString *hideBioJS = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"hideBio" withExtension:@"js"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    WKUserScript *hideBioScript = [[WKUserScript alloc] initWithSource:hideBioJS
                                                              injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                           forMainFrameOnly:YES];
    [mainWebViewConfiguration.userContentController addUserScript:hideBioScript];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:mainWebViewConfiguration];
    [self.view insertSubview:self.webView belowSubview:self.toolbar];
    
    
    [self.webView addObserver:self
                   forKeyPath:@"loading"
                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context:nil];
    
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self.webView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1
                                      constant:0];
    [self.view addConstraint:c];
    c = [NSLayoutConstraint constraintWithItem:self.webView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:1
                                      constant:0];
    [self.view addConstraint:c];
    
    NSURL *URL = [NSURL URLWithString:@"http://www.raywenderlich.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
    [self.reloadStopButton setTitle:@"X"];
    
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    NSString *fetchJSScript = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fetchAuthors" withExtension:@"js"]
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    WKUserScript *fetchAuthorsScript = [[WKUserScript alloc] initWithSource:fetchJSScript
                                                              injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                           forMainFrameOnly:YES];
    [webViewConfiguration.userContentController addUserScript:fetchAuthorsScript];
    [webViewConfiguration.userContentController addScriptMessageHandler:self
                                                                   name:MESSAGE_HANDLER];
    
    
    self.authorsWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webViewConfiguration];
    NSURL *authorsURL = [NSURL URLWithString:@"http://www.raywenderlich.com/about"];
    NSURLRequest *authorsRequest = [NSURLRequest requestWithURL:authorsURL];
    [self.authorsWebView loadRequest:authorsRequest];
  
  self.backButton.image = [UIImage imageNamed:@"icon_back"];
  self.forwardButton.image = [UIImage imageNamed:@"icon_forward"];
  self.reloadStopButton.image = [UIImage imageNamed:@"icon_stop"];
  self.backButton.enabled = self.forwardButton.enabled = NO;
  
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"loading"]) {

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:self.webView.loading];
        self.backButton.enabled = self.webView.canGoBack;
        self.forwardButton.enabled = self.webView.canGoForward;
        if (!self.webView.loading) { // to fix scroll position. Not elegant but didn't find any alternative so far
            [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:YES];
            [self.reloadStopButton setTitle:@"R"];
        } else {
            [self.reloadStopButton setTitle:@"X"];
        }
        
    } else if ([keyPath isEqualToString:@"title"]) {
        
        if (![self.webView.URL.absoluteString hasPrefix:@"http://www.raywenderlich.com/u"]) {
            
            self.title = [self.webView.title stringByReplacingOccurrencesOfString:@"Ray Wenderlich | " withString:@""];;
            
        }
        
    }
    
}

#pragma mark - Notifications

- (void) authorSelected:(NSNotification *)notification {

    [self.webView loadRequest:nil]; // To clean up previous view
    NSDictionary *author = (NSDictionary *)notification.object;
    self.title = author[@"authorName"];
    NSURL *URL = [NSURL URLWithString:author[@"authorURL"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
    
}


#pragma mark - WKScriptMessageHandler delegate

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:MESSAGE_HANDLER]) {
        if ([message.body isKindOfClass:[NSArray class]]) {
            
            self.authors = message.body;
            self.authorsButton.enabled = YES;
            
        } else {
            self.authors = nil;
            NSLog(@"suspiciously, the array returned by js is empty. Check the parsing of the page");
        }
    }
    
}

#pragma mark - Actions

- (IBAction)authorsButtonTapped:(UIBarButtonItem *)sender {
    
    [self.navigationController performSegueWithIdentifier:@"showAuthors" sender:nil];
    
}

- (IBAction)goBack:(UIBarButtonItem *)sender {
    
    [self.webView goBack];
    
}

- (IBAction)goForward:(UIBarButtonItem *)sender {
    
    [self.webView goForward];
    
}

- (IBAction)reloadStopButtonTapped:(UIBarButtonItem *)sender {
    if (self.webView.loading) {
        [self.webView stopLoading];
    } else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.webView.URL]];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    UINavigationController *navController = segue.destinationViewController;
    AuthorsTableViewController *authorsViewController = (AuthorsTableViewController *)navController.topViewController;
    authorsViewController.authors = self.authors;
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

@end
