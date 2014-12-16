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

class SettingsViewController: UIViewController, TimeZoneTableViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ColorPickerViewControllerDelegate {
  @IBOutlet var portraitLayoutConstraints: [NSLayoutConstraint]!
  @IBOutlet var LandscapeLayoutConstraints: [NSLayoutConstraint]!

  var delegate: SettingsViewControllerDelegate?

  @IBOutlet var watchView: WatchView!
  @IBOutlet var faceTypeSegmentedControl: UISegmentedControl!

  var selectedImage: UIImage?
  var selectedColor: UIColor?
  var selectedTimeZone: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Default Selected TimeZone if user did not select a timezone
    selectedTimeZone = "Asia/Singapore"
    watchView.startTimeWithTimeZone(selectedTimeZone!)
    //Create right button
    let rightButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "addWatchToList")
    navigationItem.rightBarButtonItem = rightButton
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    applyConstraintsBasedOnView(view.bounds.size)
  }
	
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func showListOfTimeZone(sender: AnyObject) {
    performSegueWithIdentifier("showTimeZones", sender: self)
  }
  
  func addWatchToList() {
    watchView.endTime()
    delegate?.didCreateNewClockSettings(watchView)
    navigationController!.popViewControllerAnimated(true)
  }
  
  @IBAction func selectClockSecondsType(sender: AnyObject) {
    let segmentedControler: UISegmentedControl = sender as UISegmentedControl
    let selectedSegment = segmentedControler.selectedSegmentIndex
    
    if selectedSegment == 0 {
      watchView.enableClockSecondHand = true
    } else {
      self.watchView.enableClockSecondHand = false
    }
    watchView.setNeedsLayout()
    watchView.layoutIfNeeded()
  }
  
  //Select an image or a color for a background
  @IBAction func selectedClockBackground(sender: AnyObject) {
    let segmentedControler: UISegmentedControl = sender as UISegmentedControl
    let selectedSegment = segmentedControler.selectedSegmentIndex
    if selectedSegment == 0 {
    if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
    UIAlertView(title: "Error", message: "Cannot access Saved Photos on device :[", delegate: nil, cancelButtonTitle: "OK").show()
    } else {
      let photoPicker: UIImagePickerController = UIImagePickerController()
      photoPicker.delegate = self
      photoPicker.allowsEditing = true
      photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
      self.showDetailViewController(photoPicker, sender: self)
      }
    } else { //segment = 1
      performSegueWithIdentifier("showColorPicker", sender: self)
      faceTypeSegmentedControl.selectedSegmentIndex = 0
    }
  }
  
  @IBAction func selectClockDesign(sender: AnyObject) {
      let segmentedControler: UISegmentedControl = sender as   UISegmentedControl
      let selectedSegment = segmentedControler.selectedSegmentIndex
      if selectedSegment == 0 {
      watchView.enableAnalogDesign = true
    } else {
      watchView.enableAnalogDesign = false
    }
    watchView.startTimeWithTimeZone(NSTimeZone.localTimeZone().name)
    watchView.setNeedsLayout()
    watchView.layoutIfNeeded()
  }
  
  //TimeZoneTableViewControllerDelegate Methods
  func didSelectATimeZone(timezone: String) {
    selectedTimeZone = timezone
    watchView.currentTimeZone = timezone
    navigationController!.popViewControllerAnimated(true)
    watchView.startTimeWithTimeZone(timezone)
  }
  
  //ColorPicker Controller Delegate
  func didSelectColor(color: UIColor!) {
    //Enable color background
    if color != nil {
      watchView.backgroundLayerColor = color
      selectedColor = color
      watchView.setNeedsLayout()
      watchView.layoutIfNeeded()
      watchView.enableColorBackground = true
      faceTypeSegmentedControl.selectedSegmentIndex = 1
    } else {
      faceTypeSegmentedControl.selectedSegmentIndex = 0
    }
  }
  
  //Invoked to open UIImagePicker to select an image.
  //Invoked to open UIImagePicker to select an image.
  func imagePickerController(picker: UIImagePickerController!,   didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
    picker.dismissViewControllerAnimated(true, completion: {
    self.watchView.backgroundImage =   info[UIImagePickerControllerEditedImage] as? UIImage
    self.selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage
    self.watchView.enableColorBackground = false
    
    //Update settings clock to show correct results
    self.watchView.setNeedsLayout()
    })
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
    dismissViewControllerAnimated(true, completion: nil)
    faceTypeSegmentedControl.selectedSegmentIndex = 1;
  }
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "showTimeZones" {
      let timeZoneTableViewController: TimeZoneTableViewController = segue.destinationViewController as TimeZoneTableViewController
      timeZoneTableViewController.delegate = self
    }
    
    if segue.identifier == "showColorPicker" {
      let colorPickerViewController: ColorPickerViewController = segue.destinationViewController as ColorPickerViewController
      colorPickerViewController.delegate = self;
    }
  }
  
  //MARK: Handling Constraint Changes on device Rotation
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    applyConstraintsBasedOnView(size)
  }

  //MARK: Helper Methods
  func applyConstraintsBasedOnView(size: CGSize) {
    let transitionToWide = size.width > size.height

    if (traitCollection.horizontalSizeClass == .Regular) {
				let constraintsToUnistall = transitionToWide ? portraitLayoutConstraints : LandscapeLayoutConstraints
				let constraintsToInstall = transitionToWide ? LandscapeLayoutConstraints : portraitLayoutConstraints
				view.layoutIfNeeded()
				
				NSLayoutConstraint.deactivateConstraints(constraintsToUnistall)
				NSLayoutConstraint.activateConstraints(constraintsToInstall)
    }
  }
}
