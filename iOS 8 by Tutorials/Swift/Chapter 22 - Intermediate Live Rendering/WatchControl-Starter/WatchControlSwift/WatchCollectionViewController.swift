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

let reuseIdentifier = "WatchCollectionCell"

class WatchCollectionViewController: UICollectionViewController, SettingsViewControllerDelegate{
	
  var listOfClocks: [WatchView] = [WatchView]()

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  //MARK: Settings View Controller Delegate
  //Notifies WatchTableViewController that a new clock has been created.
  func didCreateNewClockSettings(clock: WatchView) {
    //Add the clock to the existing clocks already being displayed
    listOfClocks.append(clock)
    //Reload the data to show the new clock.
    collectionView.reloadData()
  }

  // MARK: UICollectionViewDataSource

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

  @IBAction func clickedAddWatch(sender: AnyObject) {
    performSegueWithIdentifier("presentSettingsVC", sender: self)
  }

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return listOfClocks.count
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell { //1
    let cell : WatchCollectionViewCell =   collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as WatchCollectionViewCell
    //2
    
    if let clock = listOfClocks[indexPath.row] as WatchView? {
      //Reusing the watch view, so we just copy over the state of the cached clock
      //3
      cell.watchView?.copyClockSettings(clock)
      //4
      //Starts the clock's ticking
      cell.watchView?.startTimeWithTimeZone(clock.currentTimeZone) //5
      //Updates the time zone the watch is in.
      cell.timezoneLabel!.text = clock.currentTimeZone
      //Perform any necessary layout if needed.
      cell.watchView?.setNeedsLayout()
      cell.watchView?.layoutIfNeeded()
    }
    return cell
  }

  func collectionView(_collectionView: UICollectionView!,
    layout collectionViewLayout: UICollectionViewLayout!,
    insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    if traitCollection.horizontalSizeClass == .Regular{
      return UIEdgeInsetsMake(80, 80, 80, 80)
    } else {
      return UIEdgeInsetsMake(30, 10, 10, 10)
    }
  }

  // #pragma mark - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    //Segue to the Setting's View Controller.
    if segue.identifier == "presentSettingsVC" {
      let settingsViewController = segue.destinationViewController as SettingsViewController
      settingsViewController.delegate = self
    }
  }
}
