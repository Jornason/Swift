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

#import "RWTHistoryViewController.h"
#import "RWTBitlyHistoryService.h"
#import "RWTBitlyShortenedUrlModel.h"

@interface RWTHistoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

@end

@implementation RWTHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"History";
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[RWTBitlyHistoryService sharedService] items].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RWTBitlyShortenedUrlModel *shortUrl = [[RWTBitlyHistoryService sharedService] items][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item"];
    cell.textLabel.text = shortUrl.shortUrl.absoluteString;
    cell.detailTextLabel.text = shortUrl.longUrl.absoluteString;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RWTBitlyShortenedUrlModel *shortUrl = [[RWTBitlyHistoryService sharedService] items][indexPath.row];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Copy Link to Clipboard" message:@"Choose which link you want to copy to your clipboard." preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *copyShortLinkAction = [UIAlertAction actionWithTitle:@"Short Link" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [UIPasteboard generalPasteboard].URL = shortUrl.shortUrl;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    UIAlertAction *copyLongLinkAction = [UIAlertAction actionWithTitle:@"Long Link" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [UIPasteboard generalPasteboard].URL = shortUrl.longUrl;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    [alertController addAction:copyShortLinkAction];
    [alertController addAction:copyLongLinkAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
