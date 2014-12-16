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


extension UIViewController {
  func rwt_showVCWillResultInPush(sender: AnyObject?) -> Bool {
    if let target = targetViewControllerForAction("rwt_showVCWillResultInPush:", sender: sender) {
      return target.rwt_showVCWillResultInPush(sender)
    } else {
      return false
    }
  }
  
  func rwt_showDetailVCWillResultInPush(sender: AnyObject?) -> Bool {
    if let target = targetViewControllerForAction("rwt_showDetailVCWillResultInPush:", sender: sender) {
      return target.rwt_showDetailVCWillResultInPush(sender)
    } else {
      return false
    }
  }
}

extension UINavigationController {
  override func rwt_showVCWillResultInPush(sender: AnyObject?) -> Bool {
    return true
  }
}


extension UISplitViewController {
  override func rwt_showDetailVCWillResultInPush(sender: AnyObject?) -> Bool {
    if collapsed  {
      if let primaryVC = viewControllers.last as? UIViewController {
        return primaryVC.rwt_showVCWillResultInPush(sender)
      }
      return false
    } else {
      return false
    }
  }
}

