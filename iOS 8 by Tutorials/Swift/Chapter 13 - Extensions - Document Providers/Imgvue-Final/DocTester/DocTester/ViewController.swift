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

class ViewController: UIViewController, UIDocumentPickerDelegate {
  
  var lastURL: NSURL?
  @IBOutlet weak var imageView: UIImageView!
  
  @IBAction func open(sender: AnyObject) {
    let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeImage as NSString], inMode: .Open)
    documentPicker.delegate = self
    presentViewController(documentPicker, animated: true, completion: nil)
  }
  
  @IBAction func `import`(sender: AnyObject) {
    let documentPicker = UIDocumentPickerViewController(documentTypes:[kUTTypeImage as NSString], inMode: .Import)
    documentPicker.delegate = self
    presentViewController(documentPicker, animated: true, completion: nil)
  }
  
  @IBAction func move(sender: AnyObject) {
    downloadImage() { url in
      let documentPicker = UIDocumentPickerViewController(URL: url, inMode: .MoveToService)
      documentPicker.delegate = self
      
      let image = UIImage(contentsOfFile: url.path!)
      
      dispatch_async(dispatch_get_main_queue()) {
        self.imageView.image = image
        self.presentViewController(documentPicker, animated: true, completion: nil)
      }
    }
  }
  
  func downloadImage(completion:(url: NSURL)->()) {
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    let catURL = NSURL(string: "http://thecatapi.com/api/images/get?format=src&type=jpg")
    let task = session.downloadTaskWithURL(catURL!) { location, response, error in
      
      if error != nil {
        return
      }
      
      let docsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
      let outURL = docsURL.URLByAppendingPathComponent("temp.jpg")
      
      if let data = NSData(contentsOfURL: location) {
        data.writeToURL(outURL, atomically: true)
      }
      completion(url: outURL)
    }
    task.resume()
  }
  
  @IBAction func export(sender: AnyObject) {
    downloadImage() { url in
      let documentPicker = UIDocumentPickerViewController(URL: url, inMode: .ExportToService)
      documentPicker.delegate = self
      
      let image = UIImage(contentsOfFile: url.path!)
      
      dispatch_async(dispatch_get_main_queue()) {
        self.imageView.image = image
        self.presentViewController(documentPicker, animated: true, completion: nil)
      }
    }
  }
  
  
  //MARK: - DocumentPicker Delegate
  
  func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
    dismissViewControllerAnimated(true, completion: nil)
    lastURL = url
    switch controller.documentPickerMode {
    case .Import:
      importImage(url)
    case .Open:
      openImage(url)
    case .MoveToService:
      writeImage(url)
    case .ExportToService:
      writeImage(url)
    }
  }
  
  func importImage(url : NSURL) {
    let fileCoordinator = NSFileCoordinator(filePresenter: nil)
    
    // 1
    fileCoordinator.coordinateReadingItemAtURL(url,
      options: .WithoutChanges,
      error: nil) { newURL in
        // 2
        if let data = NSData(contentsOfURL: newURL) {
          let image = UIImage(data: data)
          self.imageView.image = image
        }
    }
  }
  
  func openImage(url : NSURL) {
    let accessing = url.startAccessingSecurityScopedResource() //1
    if accessing {
      let fileCoordinator = NSFileCoordinator(filePresenter: nil)
      fileCoordinator.coordinateReadingItemAtURL(url,
        options: .WithoutChanges,
        error: nil) { newURL in
          if let data = NSData(contentsOfURL: newURL) {
            let image = UIImage(data: data)
            self.imageView.image = image
          }
      }
      url.stopAccessingSecurityScopedResource() //2
    }
  }
  
  func writeImage(url : NSURL) {
    let im = imageView.image
    
    let fileCoordinator = NSFileCoordinator(filePresenter: nil)
    var error: NSError?
    fileCoordinator.coordinateWritingItemAtURL(url, options: .ForReplacing, error: &error) { newURL in
      let data = UIImageJPEGRepresentation(im, 0.9)
      data.writeToURL(newURL, atomically: true)
    }
    if let err = error {
      println("error writing file: \(err)")
    }
  }
  
  func documentPickerWasCancelled(controller: UIDocumentPickerViewController!) {
    if controller.documentPickerMode == .Open || controller.documentPickerMode == .Import {
      imageView.image = nil
    }
  }
  
  //MARK: - Update Image
  
  func addGreenSquareToImage(image: UIImage) -> UIImage {
    let imRect = CGRect(origin: CGPointZero, size: image.size)
    
    let halfWidth = image.size.width / 2
    let x = Int(arc4random_uniform(UInt32(halfWidth)))
    let halfHeight = image.size.height / 2
    let y = Int(arc4random_uniform(UInt32(halfHeight)))
    
    let squareRect = CGRect(x: x, y: y, width: Int(halfWidth), height: Int(halfHeight))
    println(squareRect)
    
    UIGraphicsBeginImageContext(image.size)
    image.drawInRect(imRect)
    
    let square = UIBezierPath(rect: squareRect)
    UIColor.greenColor().colorWithAlphaComponent(0.5).setFill()
    square.fill()
    let newIm = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    imageView.image = newIm
    
    return newIm
  }
  
  @IBAction func modifyImage(sender: AnyObject) {
    if let image = imageView.image {
      let newIm = addGreenSquareToImage(image)
      
      if let url = lastURL {
        let data = UIImageJPEGRepresentation(newIm, 0.9)
        
        let fileCoordinator = NSFileCoordinator()
        var error: NSError?
        fileCoordinator.coordinateWritingItemAtURL(url, options: .ForReplacing, error: &error) { newURL in
          _ = data.writeToURL(newURL, atomically: true)
        }
        if let err = error {
          println("error writing file \(error)")
        }
      }
    }
  }
}



