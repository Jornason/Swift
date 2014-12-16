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
  let weatherData = WeatherData()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      self.clearsSelectionOnViewWillAppear = false
      self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
    }
    prepareNavigationBarAppearance()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
      if let detailViewController = detailViewController {
        detailViewController.cityWeather = weatherData.cities[0]
      }
    }
    self.title = "Cities"
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
  }
  
  
  // MARK: - Segues
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow() {
        let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
        controller.cityWeather = weatherData.cities[indexPath.row]
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
      }
    }
  }
  
  // MARK: - Table View
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return weatherData.cities.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CityCell", forIndexPath: indexPath) as CityTableViewCell
    
    let city = weatherData.cities[indexPath.row]
    cell.cityWeather = city
    return cell
  }
  
  // MARK: - Utility Methods
  private func prepareNavigationBarAppearance() {
    let font = UIFont(name: "HelveticaNeue-Light", size: 30)!
    
    let regularVertical = UITraitCollection(verticalSizeClass: .Regular)
    UINavigationBar.appearanceForTraitCollection(regularVertical).titleTextAttributes = [NSFontAttributeName: font]
    
    let compactVertical = UITraitCollection(verticalSizeClass: .Compact)
    UINavigationBar.appearanceForTraitCollection(compactVertical).titleTextAttributes = [NSFontAttributeName:font.fontWithSize(20)]
  }


}

