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
import Photos
import PhotosUI
import ImgvueKit

class PhotoEditingViewController: UIViewController, PHContentEditingController {
  
  var input: PHContentEditingInput?
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var addFilterButton: UIButton!
  @IBOutlet weak var undoButton: UIButton!
  
  let filterService: ImageFilterService = ImageFilterService()
  var currentFilterName: String?
  var filteredImage: UIImage?
  
  
  @IBAction func undo(sender: UIButton) {
    if let input = input {
      imageView.image = input.displaySizeImage
      currentFilterName = nil
      filteredImage = nil
    }
  }
  
  @IBAction func addFilter(sender: UIButton) {
    let alertController =
    UIAlertController(title: "Add Filter",
      message: "Choose a filter to apply to the image",
      preferredStyle: .ActionSheet)
    for (name, filter) in filterService.availableFilters() {
      let action = UIAlertAction(title: name, style: .Default) {
        _ in
        if let input = self.input {
          self.filteredImage =
            self.filterService.applyFilter(filter, toImage:
              input.displaySizeImage)
          self.imageView.image = self.filteredImage
          self.currentFilterName = filter
        }
      }
      alertController.addAction(action)
    }
    let noneAction =
    UIAlertAction(title: "None", style: .Cancel) { action in
      if let input = self.input {
        self.imageView.image = input.displaySizeImage
        self.currentFilterName = nil
        self.filteredImage = nil
      }
    }
    alertController.addAction(noneAction)
    presentViewController(alertController, animated: true,
      completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - PHContentEditingController
  
  func canHandleAdjustmentData(adjustmentData: PHAdjustmentData?) -> Bool {
    // Inspect the adjustmentData to determine whether your extension can work with past edits.
    // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
    return false
  }
  
  func startContentEditingWithInput(contentEditingInput: PHContentEditingInput?, placeholderImage: UIImage) {
    // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
    // If you returned YES from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
    // If you returned NO, the contentEditingInput has past edits "baked in".
    
    input = contentEditingInput
    
    if let input = contentEditingInput {
      imageView.image = input.displaySizeImage
    }
  }
  
  func finishContentEditingWithCompletionHandler(completionHandler: ((PHContentEditingOutput!) -> Void)!) {
    // 1
    if currentFilterName == nil || input == nil {
      self.cancelContentEditing()
      return;
    }
    // 2
    let queuePriority = CLong(DISPATCH_QUEUE_PRIORITY_DEFAULT)
    let backgroundQueue = dispatch_get_global_queue(queuePriority,0)
    dispatch_async(backgroundQueue) {
      // 3
      let output = PHContentEditingOutput(contentEditingInput: self.input)
      // 4
      let archiveData = NSKeyedArchiver.archivedDataWithRootObject(self.currentFilterName!)
      let identifier = "com.raywenderlich.imgvue-imgvue-filters"
      let adjustmentData = PHAdjustmentData(formatIdentifier: identifier,
        formatVersion: "1.0", data: archiveData)
      output.adjustmentData = adjustmentData
      // 5
      if let path = self.input!.fullSizeImageURL.path {
        var image = UIImage(contentsOfFile: path)!
        image = self.filterService.applyFilter(self.currentFilterName!,
          toImage: image)
        // 6
        let jpegData = UIImageJPEGRepresentation(image, 1.0)
        var error: NSError?
        let saveSucceeded = jpegData.writeToURL(output.renderedContentURL,
          options: .DataWritingAtomic, error: &error)
        if saveSucceeded {
          // 7
          completionHandler(output)
        } else {
          // 8
          println("An error occurred during save: \(error)")
          completionHandler(nil)
        }
      } else {
        println("An error occurred loading the input image")
        completionHandler(nil)
      }
    }
  }
  
  var shouldShowCancelConfirmation: Bool {
    // Determines whether a confirmation to discard changes should be shown to the user on cancel.
    // (Typically, this should be "true" if there are any unsaved changes.)
    return false
  }
  
  func cancelContentEditing() {
    // Clean up temporary files, etc.
    // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
  }
  
}
