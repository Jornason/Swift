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
import S3Kit

class FileProvider: NSFileProviderExtension {

    var fileCoordinator: NSFileCoordinator {
        let fileCoordinator = NSFileCoordinator()
        fileCoordinator.purposeIdentifier = self.providerIdentifier()
        return fileCoordinator
    }

    override init() {
        super.init()
        
        self.fileCoordinator.coordinateWritingItemAtURL(self.documentStorageURL(), options: NSFileCoordinatorWritingOptions(), error: nil, byAccessor: { newURL in
            // ensure the documentStorageURL actually exists
            var error: NSError? = nil
            NSFileManager.defaultManager().createDirectoryAtURL(newURL, withIntermediateDirectories: true, attributes: nil, error: &error)
        })
    }

    override func providePlaceholderAtURL(url: NSURL, completionHandler: ((error: NSError?) -> Void)?) {
        // Should call writePlaceholderAtURL(_:withMetadata:error:) with the placeholder URL, then call the completion handler with the error if applicable.
        let fileName = url.lastPathComponent
    
        let placeholderURL = NSFileProviderExtension.placeholderURLForURL(self.documentStorageURL().URLByAppendingPathComponent(fileName))
    
        self.fileCoordinator.coordinateWritingItemAtURL(placeholderURL, options: NSFileCoordinatorWritingOptions(), error: nil, byAccessor: { newURL in
            var metadata = [NSURLFileSizeKey: fileName.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)]
            NSFileProviderExtension.writePlaceholderAtURL(placeholderURL, withMetadata: metadata, error: nil)
        })
        completionHandler?(error: nil)
    }

    override func startProvidingItemAtURL(url: NSURL, completionHandler: ((error: NSError?) -> Void)?) {
      let fileManager = NSFileManager()
      let path = url.path!
      if fileManager.fileExistsAtPath(path) { //1
        //if the file is already, just return
        completionHandler?(error: nil)
        return
      }
    
      //load the file data from Amazon S3
      let key = url.lastPathComponent //2
      let bucket = BucketInfo()
      let fileData = bucket.load(key)! //3
    
      var error: NSError? = nil
      var fileError: NSError? = nil
      fileCoordinator.coordinateWritingItemAtURL(url,
                                                 options: .ForReplacing,
                                                 error: &error,
                                                 byAccessor: { newURL in //4
        _ = fileData.writeToURL(newURL, options: .AtomicWrite, error: &fileError)
      })
      if error != nil { //5
        completionHandler?(error: error);
      } else {
         completionHandler?(error: fileError);
      }
    }

  override func itemChangedAtURL(url: NSURL) {
    // 1
    let key = url.lastPathComponent
    let bucket = BucketInfo()
  
    // 2
    fileCoordinator.coordinateReadingItemAtURL(url,
                                               options: .ForUploading,
                                               error: nil) { newURL in
      var error: NSError
      let data = NSData(contentsOfURL: newURL)!
      bucket.uploadData(data,
                        name: key,
                        completion: { error in          
          // 3
          if (error != nil) {
            println("error uploading updated file: \(error)")
          }
      })
    }
  }

    override func stopProvidingItemAtURL(url: NSURL) {
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.
        self.fileCoordinator.coordinateWritingItemAtURL(url, options: .ForDeleting, error: nil, byAccessor: { newURL in
            _ = NSFileManager.defaultManager().removeItemAtURL(newURL, error: nil)
        })
        self.providePlaceholderAtURL(url, completionHandler: nil)
    }

}
