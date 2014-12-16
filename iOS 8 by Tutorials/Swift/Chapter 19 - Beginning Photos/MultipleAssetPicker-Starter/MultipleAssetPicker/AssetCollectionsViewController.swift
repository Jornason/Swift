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

protocol AssetPickerDelegate {
  func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])
  func assetPickerDidCancel()
}

class AssetCollectionsViewController: UITableViewController {
  let AssetCollectionCellReuseIdentifier = "AssetCollectionCell"
  
  // MARK: Variables
  var delegate: AssetPickerDelegate?
  var selectedAssets: SelectedAssets?
  
  private let sectionNames = ["","","Albums"]
  private var userAlbums: PHFetchResult!
  private var userFavorites: PHFetchResult!
  
  // MARK: UIViewController
  override func viewDidLoad() {
    super.viewDidLoad()
    if selectedAssets == nil {
      selectedAssets = SelectedAssets()
    }
    
    // Check for permissions and load assets
  }
  
  override func viewWillAppear(animated: Bool)  {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    let destination = segue.destinationViewController
      as AssetsViewController
    // Set up AssetCollectionViewController
  }
  
  // MARK: Private
  func fetchCollections() {

  }
  
  func showNoAccessAlertAndCancel() {
    let alert = UIAlertController(title: "No Photo Permissions", message: "Please grant Stitch photo access in Settings -> Privacy", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
      self.cancelPressed(self)
    }))
    alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
      UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
      return
    }))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: Actions
  @IBAction func donePressed(sender: AnyObject) {
    delegate?.assetPickerDidFinishPickingAssets(selectedAssets!.assets)
  }
  
  @IBAction func cancelPressed(sender: AnyObject) {
    delegate?.assetPickerDidCancel()
  }
  
  // MARK: UITableViewDataSource
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sectionNames.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch(section) {
    case 0: // Selected Section
      return 1
    case 1: // All Photos + Favorites
      return 1
    case 2: // Albums
      return 0
    default:
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(AssetCollectionCellReuseIdentifier, forIndexPath: indexPath) as UITableViewCell
    cell.detailTextLabel!.text = ""
    
    // Populate the table cell
    
    return cell
  }
}
