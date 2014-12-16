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

class MasterViewController: UITableViewController {
  
  var detailViewController: DetailViewController? = nil
  var paletteCollection: ColorPaletteCollection = ColorPaletterProvider().rootCollection!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    title = "Palettes"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = controllers.last?.topViewController as? DetailViewController
    }
  }

  
  // #pragma mark - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return paletteCollection.children.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    let object = paletteCollection.children[indexPath.row]
    cell.textLabel.text = object.name
    return cell
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    // Make sure that on iPad we see the disclosure indicators as expected
    if(UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
      if rowHasChildrenAtIndex(indexPath) {
        cell.accessoryType = .DisclosureIndicator
      } else {
        cell.accessoryType = .None
      }
    }
  }
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if(rowHasChildrenAtIndex(indexPath)) {
      let childCollection = paletteCollection.children[indexPath.row] as ColorPaletteCollection
      let newTable = storyboard?.instantiateViewControllerWithIdentifier("MasterVC") as MasterViewController
      newTable.paletteCollection = childCollection
      newTable.title = childCollection.name
      navigationController?.pushViewController(newTable, animated: true)
    }
  }
  
  // #pragma mark - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow() {
        let detailNav = segue.destinationViewController as UINavigationController
        let detailVC  = detailNav.topViewController as DetailViewController
        let palette   = paletteCollection.children[indexPath.row] as ColorPalette
        detailVC.colorPalette = palette
      }
    }
  }
  
  override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
    if let selectedIndexPath = tableView.indexPathForSelectedRow() {
      return !rowHasChildrenAtIndex(selectedIndexPath)
    }
    return false
  }
  
  
  // Private methods
  private func rowHasChildrenAtIndex(indexPath: NSIndexPath) -> Bool {
    let item = paletteCollection.children[indexPath.row]
    if let itemAsPalette = item as? ColorPaletteCollection {
      return true
    }
    return false
  }
  
}
