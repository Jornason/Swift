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

import UIKit
import MobileCoreServices
import BitlyKit

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
  
  var extensionContext: NSExtensionContext?
  
  func beginRequestWithExtensionContext
    (context: NSExtensionContext)
  {
    self.extensionContext = context
    
    // 1
    let extensionItem = context.inputItems.first as? NSExtensionItem
    if (extensionItem == nil) {
      self.doneWithResults(nil)
      return
    }
    
    // 2
    let itemProvider = extensionItem!.attachments?.first
      as? NSItemProvider
    if (itemProvider == nil) {
      self.doneWithResults(nil)
      return
    }
    
    // 3
    let propertyListType = String(kUTTypePropertyList)
    if itemProvider!.hasItemConformingToTypeIdentifier(propertyListType) {
      itemProvider!.loadItemForTypeIdentifier(propertyListType,
        options: nil)
        { item, error in
          let dictionary = item as NSDictionary
          NSOperationQueue.mainQueue().addOperationWithBlock {
            // 4
            var results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey]
              as NSDictionary
            self.itemLoadCompletedWithPreprocessingResults(results)
          }
      }
    } else {
      self.doneWithResults(nil)
    }
  }
  
  func itemLoadCompletedWithPreprocessingResults
    (javaScriptPreprocessingResults: NSDictionary) {
      // 1
      let currentUrlString =
      javaScriptPreprocessingResults["currentUrl"] as? String
      if currentUrlString != nil &&
        currentUrlString!.isEmpty == false {
          // 2
          let bitlyService = BitlyService(accessToken: "YOUR_ACCESS_TOKEN")
          let longUrlOpt: NSURL? = NSURL(string: currentUrlString!)
          if let longUrl = longUrlOpt {
            //3
            bitlyService.shortenUrl(longUrl, domain: "bit.ly") {
              shortenedUrl, error in
              if let error = error {
                // 4
                self.doneWithResults(["error" : error.description])
              } else {
                // 5
                if let shortUrl = shortenedUrl?.shortUrl {
                  UIPasteboard.generalPasteboard().string = shortUrl.absoluteString
                  let results = ["shortUrl" : shortUrl.absoluteString ?? ""];
                  // 6
                  let historyService = BitlyHistoryService.sharedService
                  historyService.addItem(shortenedUrl!)
                  historyService.persistItemsArray()
                  // 7
                  self.doneWithResults(results)
                } else {
                  self.doneWithResults(["error" : "Unable to shorten URL."])
                }
              }
            }
          }
      }
  }

  
  func doneWithResults
    (resultsForJavaScriptFinalizeArg: NSDictionary?) {
      if let results = resultsForJavaScriptFinalizeArg {
        // 1
        var resultsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: results]
        
        // 2
        let itemType = kUTTypePropertyList as NSString as String
        var resultsProvider = NSItemProvider(item: resultsDictionary,
          typeIdentifier: itemType)
        
        // 3
        var resultsItem = NSExtensionItem()
        resultsItem.attachments = [resultsProvider]
        
        // 4
        extensionContext!.completeRequestReturningItems([resultsItem],
          completionHandler: nil)
      } else {
        
        // 5
        extensionContext!.completeRequestReturningItems(nil,
          completionHandler: nil)
      }
      
      // 6
      extensionContext = nil
  }
  
}
