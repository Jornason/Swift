//
//  AuthorsTableViewController.m
//  RWPedia
//
//  Created by Cesare Rocchi on 6/30/14.
//  Copyright (c) 2014 Cesare Rocchi. All rights reserved.
//

#import "AuthorsTableViewController.h"
#import <WebKit/WebKit.h>
#import "WebViewController.h"

@interface AuthorsTableViewController () <WKScriptMessageHandler>

@property (nonatomic, strong) NSArray *authors;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) WKWebView *authorsWebView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;



- (IBAction)close:(UIBarButtonItem *)sender;

@end

@implementation AuthorsTableViewController

static NSString * const MessageHandlerName = @"didFetchAuthors";

- (instancetype)initWithStyle:(UITableViewStyle)style {
    
    self = [super initWithStyle:style];
    if (self) {
        _spinner.hidesWhenStopped = YES;
    }
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Authors";
    self.spinner.hidesWhenStopped = YES;
    self.sectionTitles = @[@"Team Authors", @"Update Team", @"Code Team", @"Editorial Team", @"Translation Team lead", @"Translation team", @"Subject Matter Expert", @"Reader App Reviews", @"Site Admins"];
    
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    
    NSString *jsScript = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fetchAuthors" withExtension:@"js"]
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    
    WKUserScript *fetchAuthorsScript = [[WKUserScript alloc] initWithSource:jsScript
                                                              injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                           forMainFrameOnly:YES];
    [webViewConfiguration.userContentController addUserScript:fetchAuthorsScript];
    [webViewConfiguration.userContentController addScriptMessageHandler:self
                                                                   name:MessageHandlerName];
    
    self.authorsWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webViewConfiguration];
    NSURL *URL = [NSURL URLWithString:@"http://www.raywenderlich.com/about"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.authorsWebView loadRequest:request];
    [self.spinner startAnimating];
    
}

- (IBAction)close:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - WKScriptMessageHandler delegate

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:MessageHandlerName]) {
        if ([message.body isKindOfClass:[NSArray class]]) {
            
            [self.spinner stopAnimating];
            self.authors = message.body;
            [self.tableView reloadData];
            
        } else {
            self.authors = nil;
            NSLog(@"suspiciously, the array returned by js is empty. Check the parsing of the page");
        }
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.authors.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *arrayForSection = self.authors[section];
    return arrayForSection.count;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return self.sectionTitles[section];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"authorCellID" forIndexPath:indexPath];
    NSArray *sectionArray = self.authors[indexPath.section];
    NSDictionary *author = sectionArray[indexPath.row];
    cell.textLabel.text = @"";
    //if (![author[@"authorName"] isKindOfClass:[NSNull class]])
    {
        cell.textLabel.text = author[@"authorName"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *sectionArray = self.authors[indexPath.section];
    NSDictionary *author = sectionArray[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:AUTHOR_SELECTED object:author];
    [self close:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
