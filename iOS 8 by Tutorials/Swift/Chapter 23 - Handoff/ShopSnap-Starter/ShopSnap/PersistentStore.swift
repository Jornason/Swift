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
import Foundation

/** A simple persistent store mechanism to store shopping list items across multiple sessions of the app. */
class PersistentStore: NSObject {
  
  let StoreFileName = "RWTStore"
  
  /** Items in the store. To update call updateStoreWithItems(). To save it call commit(). */
  private var items = [String]()
  
  var storeURL: NSURL? {
    get {
      var error: NSError?
      var URL: NSURL? = NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: nil)
      if let docURL = URL {
        let storeURL = docURL.URLByAppendingPathComponent(StoreFileName)
        return storeURL
      } else {
        NSLog("Error getting user documents directory: \(error?.localizedDescription)")
      }
      return nil
    }
  }
  
  // MARK: Public
  
  /** Designated initializer. Returns a shared instance of the store. */
  class func defaultStore() -> PersistentStore {
    struct SharedInstance {
      static let instance = PersistentStore()
    }
    return SharedInstance.instance
  }
  
  /** Items that are stored in the store. Everytime you call this method, it read from local disk. */
  func fetchItems(completion: (items:[String]) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
      
      // Load previously saved items, if any.
      var unarchived: [String]?
      if let path = self.storeURL?.relativePath {
        unarchived = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as [String]?
      }
      if let savedItems = unarchived {
        self.items += savedItems
      }
      dispatch_async(dispatch_get_main_queue(), {
        completion(items: self.items)
      })
    })
  }
  
  /** Updates items in the store with the new ones. */
  func updateStoreWithItems(newItems: [String]) {
    items = newItems
  }
  
  /** Commit and save items in the store to the disk. */
  func commit() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
      if let path = self.storeURL?.relativePath {
        let success = NSKeyedArchiver.archiveRootObject(self.items, toFile: path)
        println("Commited \(countElements(self.items)) items: \(success)")
      }
    })
  }
  
}
