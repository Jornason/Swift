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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
    if let window = self.window {
      UINavigationBar.appearance().setBackgroundImage(UIImage(named: "backgroundImage"), forBarMetrics: .Default)
      UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
      window.tintColor = UIColor.whiteColor()
    }
    return true
  }
  
  // MARK: Handoff
  
  func application(application: UIApplication!, continueUserActivity userActivity: NSUserActivity!, restorationHandler: (([AnyObject]!) -> Void)!) -> Bool {
    if let userInfo: NSDictionary = userActivity.userInfo {
      if let version = userInfo[ActivityVersionKey] as? String {
        // Pass it on.
        if let window = self.window {
          window.rootViewController?.restoreUserActivityState(userActivity)
        }
        return true
      }
    }
    return false
  }
  
  func application(application: UIApplication, willContinueUserActivityWithType userActivityType: String!) -> Bool {
    return true
  }
  
  func application(application: UIApplication!, didFailToContinueUserActivityWithType userActivityType: String!, error: NSError!) {
    if error.code != NSUserCancelledError {
      let message = "The connection to your other device may have been interrupted. Please try again. \(error.localizedDescription)"
      let alertView = UIAlertView(title: "Handoff Error", message: message, delegate: nil, cancelButtonTitle: "Dismiss")
      alertView.show()
    }
  }
  
  func application(application: UIApplication, didUpdateUserActivity userActivity: NSUserActivity) {
    userActivity.addUserInfoEntriesFromDictionary([ActivityVersionKey: ActivityVersionValue])
  }
  
}
