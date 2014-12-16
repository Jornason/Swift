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

#import "ActionRequestHandler.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "RWTBitlyService.h"
#import "RWTBitlyShortenedUrlModel.h"
#import "RWTBitlyHistoryService.h"

@interface ActionRequestHandler ()

@property (nonatomic, strong) NSExtensionContext *extensionContext;

@end

@implementation ActionRequestHandler

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
  self.extensionContext = context;
  
  NSExtensionItem *extensionItem = context.inputItems.firstObject;
  if (extensionItem == nil) {
    [self doneWithResults:nil];
    return;
  }
  
  
  NSItemProvider *itemProvider = extensionItem.attachments.firstObject;
  if (itemProvider == nil) {
    [self doneWithResults:nil];
    return;
  }
  
  if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
    [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList
                                    options:nil
                          completionHandler:^(id<NSSecureCoding> item, NSError *error)
    {
      NSDictionary *dictionary = (NSDictionary *)item;
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSDictionary *results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey];
        [self itemLoadCompletedWithPreprocessingResults:results];
      }];
    }];
  } else {
    [self doneWithResults:nil];
  }
}

- (void)itemLoadCompletedWithPreprocessingResults:(NSDictionary *)javaScriptPreprocessingResults {
  NSString *currentUrlString = javaScriptPreprocessingResults[@"currentUrl"];
  if (currentUrlString != nil && currentUrlString.length > 0) {
#warning ADD YOUR ACCESS TOKEN
    RWTBitlyService *bitlyService = [[RWTBitlyService alloc] initWithOAuthAccessToken:@"YOUR_ACCESS_TOKEN"];
    NSURL *longUrl = [NSURL URLWithString:currentUrlString];
    if (longUrl != nil) {
      [bitlyService shortenUrl:longUrl
                        domain:@"bit.ly"
                    completion:^(RWTBitlyShortenedUrlModel *shortenedUrl, NSError *error)
      {
        if (error != nil) {
          [self doneWithResults:@{@"error": error.description}];
        } else {
          NSURL *shortUrl = shortenedUrl.shortUrl;
          [UIPasteboard generalPasteboard].URL = shortUrl;
          NSDictionary *results = @{@"shortUrl": shortUrl.absoluteString};
          RWTBitlyHistoryService *historyService = [[RWTBitlyHistoryService alloc] init];
          [historyService addItem:shortenedUrl];
          [historyService persistItemsArray];
          [self doneWithResults:results];
        }
      }];
    }
  }
}

- (void)doneWithResults:(NSDictionary *)resultsForJavaScriptFinalize {
  if (resultsForJavaScriptFinalize) {
    
    NSDictionary *resultsDictionary = @{NSExtensionJavaScriptFinalizeArgumentKey: resultsForJavaScriptFinalize};
    
    NSItemProvider *resultsProvider = [[NSItemProvider alloc] initWithItem:resultsDictionary
                                                            typeIdentifier:(NSString *)kUTTypePropertyList];
    
    NSExtensionItem *resultsItem = [[NSExtensionItem alloc] init];
    resultsItem.attachments = @[resultsProvider];
    
    [self.extensionContext completeRequestReturningItems:@[resultsItem] completionHandler:nil];
  } else {
    [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
  }
  
  self.extensionContext = nil;
}

@end
