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
import Social
import ImgvueKit
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
  
  var imageToShare: UIImage?
  
  override func viewDidLoad() {
    // 1
    let items = extensionContext?.inputItems
    var itemProvider: NSItemProvider?
    
    // 2
    if items != nil && items!.isEmpty == false {
      let item = items![0] as NSExtensionItem
      if let attachments = item.attachments {
        if !attachments.isEmpty {
          // 3
          itemProvider = attachments[0] as? NSItemProvider
        }
      }
    }
    
    // 4
    let imageType = kUTTypeImage as NSString as String
    if itemProvider?.hasItemConformingToTypeIdentifier(imageType) == true
    {
      // 5
      itemProvider?.loadItemForTypeIdentifier(imageType,
        options: nil)
        { item, error in
          if error == nil {
            // 6
            let url = item as NSURL
            if let imageData = NSData(contentsOfURL: url) {
              self.imageToShare = UIImage(data: imageData)
            }
          } else {
            // 7
            let title = "Unable to load image"
            let message = "Please try again or choose a different image."
            
            let alert = UIAlertController(title: title,
              message: message,
              preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "Bummer",
              style: .Cancel)
              { _ in
                self.dismissViewControllerAnimated(true,
                  completion: nil)
            }
            
            alert.addAction(action)
            self.presentViewController(alert, animated: true,
              completion: nil)
          }
      }
    }
  }
  
  func shareImage() {
    // 1
    let defaultSession = ImgurService.sharedService.session
    let defaultConfig = defaultSession.configuration
    let defaultHeaders = defaultConfig.HTTPAdditionalHeaders
    
    // 2
    let sessionId = "com.raywenderlich.imgvue.backgroundsession"
    let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(sessionId)
    
    config.sharedContainerIdentifier =
    "group.com.raywenderlich.swift.imgvue"
    
    config.HTTPAdditionalHeaders = defaultHeaders
    
    // 3
    let backgroundSession = NSURLSession(configuration: config,
      delegate: ImgurService.sharedService,
      delegateQueue: NSOperationQueue.mainQueue())
    
    // 4
    let completion: (ImgurImage?, NSError?) -> () =
    { image, error in
      if error == nil {
        if let imageLink = image?.link {
          UIPasteboard.generalPasteboard().URL = imageLink
          NSLog("Image shared: %@", imageLink.absoluteString!)
        }
      } else {
        NSLog("Error sharing image: %@", error!)
      }
      
    }
    
    // 5
    let progressCallback: (Float) -> () = { progress in
      println("Upload progress for extension: \(progress)")
    }
    
    // 6
    let title = contentText
    ImgurService.sharedService.uploadImage(imageToShare!,
      title: title,
      session: backgroundSession,
      completion:completion,
      progressCallback:progressCallback)
    
    // 7
    self.extensionContext?.completeRequestReturningItems([], nil)
  }
  
  
  override func isContentValid() -> Bool {
    // Do validation of contentText and/or NSExtensionContext attachments here
    if imageToShare == nil {
      return false
    }
    
    return true
  }
  
  override func didSelectPost() {
    shareImage()
  }
  
  override func configurationItems() -> [AnyObject]! {
    let configItem = SLComposeSheetConfigurationItem()
    configItem.title = "URL will be copied to clipboard"
    
    return [configItem]
  }
  
}
