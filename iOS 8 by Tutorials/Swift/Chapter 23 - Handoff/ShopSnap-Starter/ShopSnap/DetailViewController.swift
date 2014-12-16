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

protocol DetailViewControllerDelegate : class {
  func detailViewController(#controller: DetailViewController, didFinishWithUpdatedItem item: String)
}

class DetailViewController: UITableViewController, UITextFieldDelegate {
  
  // MARK: Public
  
  /** An item to be displayed. */
  var item: String? {
    didSet {
      if let textField = self.textField {
        textField.text = item
      }
    }
  }
  
  /** A delegate to get notified about changes in item. */
  var delegate: DetailViewControllerDelegate?
  
  /** Starts editing by making the text field become first responder. */
  func startEditing() {
    textField!.becomeFirstResponder()
  }
  
  /** Stops editing by making the text field resign first responder. */
  func stopEditing() {
    textField!.resignFirstResponder()
  }
  
  @IBOutlet var textField: UITextField?
  
  // MARK: View Life Cycle
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewDidLoad() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldTextDidChange:", name: UITextFieldTextDidChangeNotification, object: nil)
    textField!.text = item
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool)  {
    if self.traitCollection.horizontalSizeClass == .Compact {
      startEditing()
    }
    super.viewDidAppear(animated)
  }
  
  // MARK: UITextFieldDelegate
  
  func textFieldDidBeginEditing(textField: UITextField!) {
  }
  
  func textFieldShouldReturn(textField: UITextField!) -> Bool {
    textField.resignFirstResponder()
    delegate?.detailViewController(controller: self, didFinishWithUpdatedItem: textField.text)
    return true
  }
  
  // MARK: NSNotification
  
  func textFieldTextDidChange(notification: NSNotification) {
    if let text = textField!.text  {
      item = text
    }
  }
  
}