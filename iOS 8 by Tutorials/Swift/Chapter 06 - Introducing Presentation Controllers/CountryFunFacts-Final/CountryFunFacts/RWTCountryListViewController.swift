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

class RWTCountryListViewController: UITableViewController,
RWTCountryResultsControllerDelegate  {

  
  var countryDetailViewController: RWTCountryDetailViewController? = nil
  var countries = RWTCountry.countries()
  var searchController: UISearchController? = nil
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.clearsSelectionOnViewWillAppear = false
    self.preferredContentSize =
      CGSize(width: 320.0, height: 600.0)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Countries"
    
    let controllers = splitViewController!.viewControllers
    countryDetailViewController =
      controllers[controllers.endIndex-1].topViewController
      as? RWTCountryDetailViewController
    
    // Set the details controller with the
    // first country in the array
    let country = countries[0] as RWTCountry
    countryDetailViewController?.country = country
    
    addSearchBar()
  }
  
  // #pragma mark - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue,
    sender: AnyObject?) {
      
      if segue.identifier == "showDetail" {
        var country : RWTCountry? = nil
        if searchController!.active {
          let resultsController =
          searchController!.searchResultsController as
          RWTCountryResultsController
          let indexPath =
          resultsController.tableView.indexPathForSelectedRow()
          country =
            resultsController.filteredCountries[indexPath!.row]
            as? RWTCountry
        } else {
          let indexPath = self.tableView.indexPathForSelectedRow()
          country = countries[indexPath!.row] as? RWTCountry
        }
        let navController = segue.destinationViewController as UINavigationController
        let topViewController = navController.topViewController as RWTCountryDetailViewController
        topViewController.country = country
      }
  }

  
  // #pragma mark - Table View
  
  override func numberOfSectionsInTableView(tableView:
    UITableView) -> Int {
      
      return 1
  }
  
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      
      return countries.count
  }
  
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
      
      var cell =
      tableView.dequeueReusableCellWithIdentifier("Cell",
        forIndexPath: indexPath) as RWTCountryTableViewCell
      
      let country = countries[indexPath.row] as RWTCountry
      cell.configureCellForCountry(country)
      return cell
  }
  
  override func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
      let country = countries[indexPath.row] as RWTCountry
      countryDetailViewController?.country = country
  }
  
  func addSearchBar() {
    var resultsController = RWTCountryResultsController()
    resultsController.countries = countries
    resultsController.delegate = self
    
    searchController = UISearchController(searchResultsController:
      resultsController)
    
    searchController!.searchResultsUpdater = resultsController
    
    searchController!.searchBar.frame = CGRect(
      x: searchController!.searchBar.frame.origin.x,
      y: searchController!.searchBar.frame.origin.y,
      width: searchController!.searchBar.frame.size.width,
      height: 44.0)
    
    tableView.tableHeaderView = searchController!.searchBar
    self.definesPresentationContext = true
    
  }

  // #pragma mark - RWTCountryResultsControllerDelegate
  
  func searchCountrySelected() {
    performSegueWithIdentifier("showDetail", sender: nil)
  }
}
