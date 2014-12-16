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
import UIWidgets
import S3Kit

class DocumentPickerViewController: UIDocumentPickerExtensionViewController, ThumbnailDelegate, NSFileManagerDelegate, UploadControllerDelegate {

  override func prepareForPresentationInMode(mode: UIDocumentPickerMode) {
    super.prepareForPresentationInMode(mode)
    
    let vc = self.childViewControllers;
    let nav = vc.first as UINavigationController
    
    let thumbController = nav.topViewController as ThumbnailCollectionViewController
    
    thumbController.navigationController?.setNavigationBarHidden(true, animated: false)
    if mode == .ExportToService || mode == .MoveToService {
      thumbController.performSegueWithIdentifier("upload", sender: nil)
    } else {
      thumbController.delegate = self
    }
  }
  
  // MARK: ThumbnailDelegate
  func didSelectImage(image: S3Image) {
    let imageUrl = image.url!
    
    //1
    let filename = imageUrl.pathComponents.last as String
    
    //2
    let outUrl = documentStorageURL.URLByAppendingPathComponent(filename)
    
    // 3
    let coordinator = NSFileCoordinator()
    coordinator.coordinateWritingItemAtURL(outUrl,
                                           options: .ForReplacing,
                                           error: nil,
                                           byAccessor: { newURL in
      //4
      let fm = NSFileManager()
      fm.delegate = self
      fm.copyItemAtURL(imageUrl, toURL: newURL, error: nil)
    })
    
    // 5
    dismissGrantingAccessToURL(outUrl)
  }
  
  // MARK: NSFileManagerDelegate
  func fileManager(fileManager: NSFileManager,
      shouldProceedAfterError error: NSError,
      copyingItemAtURL srcURL: NSURL,
      toURL dstURL: NSURL) -> Bool {
      
      return true
  }

  // MARK: UploadControllerDelegate
  func nameChosen(name: String) {
    let justFilename = name.stringByDeletingPathExtension
    let exportURL = documentStorageURL.URLByAppendingPathComponent(name).URLByAppendingPathExtension("jpg")
    upload(name, outURL: exportURL)
  }

  func upload(name: String, outURL: NSURL) {
    let access = originalURL!.startAccessingSecurityScopedResource() //1
    if access {
      let fc = NSFileCoordinator()
      var error: NSError?
      fc.coordinateReadingItemAtURL(originalURL!, //2
        options: .ForUploading,
        error: &error) { url in
          let bucket = BucketInfo() //3
          let data = NSData(contentsOfURL: url)!
          bucket.uploadData(data, name: name) { error in //4
            if error != nil {
              println("error uploading: \(error)")
            }
          }
          data.writeToURL(outURL, atomically: true) //5
          self.dismissGrantingAccessToURL(outURL) //6
      }
      originalURL!.stopAccessingSecurityScopedResource()
    }
  }
}
