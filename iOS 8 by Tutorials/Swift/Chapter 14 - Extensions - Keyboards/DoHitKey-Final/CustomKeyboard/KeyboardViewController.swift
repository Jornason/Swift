//  KeyboardViewController.swift

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
import CoreLocation

let TagForSpecialButtons = 99

let ScaleSizeOnTap: CGFloat!  = 2.5
let ScaleSpeedOnTap = 0.10

let ShiftAutoOff = true

class KeyboardViewController: UIInputViewController, CLLocationManagerDelegate {
  
  var themeData: [KeyboardThemeData] = []
  var currentThemeID: Int!
  var shiftOn = false
  
  @IBOutlet weak var containerView: UIView!
  
  @IBOutlet weak var background: UIView!
  @IBOutlet weak var rowCustom: UIView!
  @IBOutlet weak var row1: UIView!
  @IBOutlet weak var row2: UIView!
  @IBOutlet weak var row3: UIView!
  @IBOutlet weak var row4: UIView!
  
  @IBOutlet weak var rowCustomAlt1: UIView!
  @IBOutlet weak var rowCustomAlt2: UIView!
  @IBOutlet weak var rowCustomAlt3: UIView!
  @IBOutlet weak var rowCustomAlt4: UIView!
  
  @IBOutlet weak var btnTheme1: UIButton!
  @IBOutlet weak var btnTheme2: UIButton!
  @IBOutlet weak var btnTheme3: UIButton!
  @IBOutlet weak var btnTheme4: UIButton!
  
  @IBOutlet var btnLocation: UIButton!
  
  var locationManager: CLLocationManager!
  var currentLocation: CLLocation!
  
  // MARK: View Appear / Disappear
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let nib = UINib(nibName: "KeyboardView", bundle: nil)
    let objects = nib.instantiateWithOwner(self, options: nil)
    containerView = objects[0] as UIView
    
    view = containerView;
    
    configureGesturesForView(rowCustomAlt1)
    configureGesturesForView(rowCustomAlt2)
    configureGesturesForView(rowCustomAlt3)
    configureGesturesForView(rowCustomAlt4)
    
    themeData = KeyboardThemeData.configureThemeData()
    
    getCurrentAppSettings()
    configureCoreLocationManager()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: Style Keyboard for Selected Theme
  
  func defaultsDidChange(notification: NSNotification) {
  }
  
  func getCurrentAppSettings() {
    let defaults = NSUserDefaults.standardUserDefaults()
    currentThemeID = defaults.integerForKey(ThemePreference)
    
    styleKeyboardWithThemeID(currentThemeID)
  }
  
  func styleThemeButton(button: UIButton,  theme:KeyboardThemeData) {
    let image = UIImage(named: "whiteLine")?.imageWithRenderingMode(.AlwaysTemplate)
    button.selected = false
    button.setBackgroundImage(image, forState: .Selected)
    button.tintColor = theme.colorForButtonFont
  }
  
  func styleKeyboardWithThemeID(themeID: Int) {
    
    var currentTheme = themeData[themeID]
    
    /* Reset theme buttons */
    styleThemeButton(btnTheme1, theme: currentTheme)
    styleThemeButton(btnTheme2, theme: currentTheme)
    styleThemeButton(btnTheme3, theme: currentTheme)
    styleThemeButton(btnTheme4, theme: currentTheme)
    
    /* Set selected theme button */
    switch themeID {
    case 0:
      btnTheme1.selected = true
    case 1:
      btnTheme2.selected = true
    case 2:
      btnTheme3.selected = true
    case 3:
      btnTheme4.selected = true
    default:
      btnTheme1.selected = true
    }
    
    /* Handle Tint Color for Location Button */
    let image = UIImage(named: "pin")?.imageWithRenderingMode(.AlwaysTemplate)
    btnLocation.setImage(image, forState: .Normal)
    btnLocation.tintColor = currentTheme.colorForButtonFont
    
    /* Set Colors */
    containerView.backgroundColor = currentTheme.colorForBackground;
    
    rowCustom.backgroundColor = currentTheme.colorForCustomRow;
    row1.backgroundColor = currentTheme.colorForRow1;
    row2.backgroundColor = currentTheme.colorForRow2;
    row3.backgroundColor = currentTheme.colorForRow3;
    row4.backgroundColor = currentTheme.colorForRow4;
    
    rowCustomAlt1.backgroundColor = currentTheme.colorForCustomRow;
    rowCustomAlt2.backgroundColor = currentTheme.colorForCustomRow;
    rowCustomAlt3.backgroundColor = currentTheme.colorForCustomRow;
    rowCustomAlt4.backgroundColor = currentTheme.colorForCustomRow;
    
    /* Set Button Case */
    setButtonCase();
    
    /* Set Button Fonts */
    setButtonFont(rowCustom , theme: currentTheme)
    setButtonFont(rowCustomAlt1 , theme: currentTheme)
    setButtonFont(rowCustomAlt2 , theme: currentTheme)
    setButtonFont(rowCustomAlt3 , theme: currentTheme)
    setButtonFont(rowCustomAlt4 , theme: currentTheme)
    
    setButtonFont(row1 , theme: currentTheme)
    setButtonFont(row2 , theme: currentTheme)
    setButtonFont(row3 , theme: currentTheme)
    setButtonFont(row4 , theme: currentTheme)
  }
  
  func setButtonCase() {
    setShiftStatus(row1)
    setShiftStatus(row2)
    setShiftStatus(row3)
    setShiftStatus(row4)
  }
  
  func setButtonFont(viewWithButtons: UIView, theme:KeyboardThemeData) {
    for view in viewWithButtons.subviews {
      if let button = view as? UIButton {
        button.titleLabel!.font = theme.keyboardButtonFont;
        button.setTitleColor(theme.colorForButtonFont,
          forState: .Normal)
        
        if button.tag == TagForSpecialButtons {
          button.titleLabel!.font = UIFont(name: button.titleLabel!.font.fontName,
            size: SpecialButtonFontSize)
        }
      }
    }
  }
  
  func setShiftStatus(viewWithButtons: UIView) {
    for view in viewWithButtons.subviews {
      if let button = view as? UIButton {
        let buttonText = button.titleLabel!.text
        if shiftOn {
          if button.tag != TagForSpecialButtons {
            let text = buttonText!.uppercaseString
            button.setTitle("\(text)", forState: .Normal)
          }
        } else {
          let text = buttonText!.lowercaseString
          button.setTitle("\(text)", forState: .Normal)
        }
      }
    }
  }
  
  // MARK: - Button Actions, Standard Keys
  
  @IBAction func btnAdvanceToNextInputModeTap(button: UIButton) {
    advanceToNextInputMode()
  }
  
  // MARK: Button Actions, Special Keys
  
  @IBAction func btnShiftKeyTap(button: UIButton) {
    shiftOn = !shiftOn
    setButtonCase()
  }
  
  @IBAction func btnKeyPressedTap(button: UIButton) {
    var string = button.titleLabel!.text
    (textDocumentProxy as UIKeyInput).insertText("\(string!)")
    
    if (ShiftAutoOff) {
      shiftOn = false
      setButtonCase()
    }
    animateButtonTapForButton(button)
  }
  
  @IBAction func btnBackspaceKeyTap(button: UIButton) {
    (textDocumentProxy as UIKeyInput).deleteBackward()
  }
  
  @IBAction func btnSpacebarKeyTap(button: UIButton) {
    (textDocumentProxy as UIKeyInput).insertText(" ")
  }
  
  @IBAction func btnReturnKeyTap(button: UIButton) {
    (textDocumentProxy as UIKeyInput).insertText("\n")
  }
  
  @IBAction func btnChangeThemeTap(button: UIButton) {
    button.selected = true
    
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setInteger(button.tag, forKey: ThemePreference)
    defaults.synchronize()
    
    currentThemeID = defaults.integerForKey(ThemePreference)
    
    styleKeyboardWithThemeID(currentThemeID)
  }
  
  @IBAction func btnChangeAltRowTap(button: UIButton) {
    rowCustom.hidden = true
    
    rowCustomAlt1.hidden = true
    rowCustomAlt2.hidden = true
    rowCustomAlt3.hidden = true
    rowCustomAlt4.hidden = true
    
    if button.titleLabel!.text == "#1" {
      rowCustom.hidden = true
      rowCustomAlt1.hidden = false
      button.setTitle("#2", forState: .Normal)
    } else if button.titleLabel!.text == "#2" {
      rowCustom.hidden = true
      rowCustomAlt2.hidden = false
      button.setTitle("#3", forState: .Normal)
    } else if button.titleLabel!.text == "#3" {
      rowCustom.hidden = true
      rowCustomAlt3.hidden = false
      button.setTitle("#4", forState: .Normal)
    } else if button.titleLabel!.text == "#4" {
      rowCustom.hidden = true
      rowCustomAlt4.hidden = false
      button.setTitle("#0", forState: .Normal)
    } else if button.titleLabel!.text == "#0" {
      rowCustom.hidden = false
      button.setTitle("#1", forState: .Normal)
    }
  }
  
  @IBAction func btnLocationTap(button: UIButton) {
    if (currentLocation != nil) {
      let string = "\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)"
      (textDocumentProxy as UIKeyInput).insertText(string)
    }
  }
  
  // MARK: Location Services
  
  func configureCoreLocationManager() {
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 30
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    btnLocation.enabled = false
  }
  
  func locationManager(manager:CLLocationManager!, didUpdateLocations locations:[AnyObject]!) {
    currentLocation = locations.first as CLLocation
    btnLocation.enabled = true
  }
  
  // MARK: Button Animations
  
  func animateButtonTapForButton(button: UIButton) {
    UIView.animateWithDuration(ScaleSpeedOnTap, animations: {
      button.transform = CGAffineTransformScale(CGAffineTransformIdentity,
        ScaleSizeOnTap,
        ScaleSizeOnTap)
      }, completion: {(_) -> Void in
        button.transform = CGAffineTransformScale(CGAffineTransformIdentity,
          1,
          1)
    })
  }
  
  // MARK: Swipe Gesture Configuration and Methods
  
  /* This configures the custom row to input numbers 1 - 0 when the user swipes up */
  
  func configureGesturesForView(view: UIView) {
    for index in 1...10 {
      let button: UIButton? = view.viewWithTag(index) as? UIButton;
      let swipeUp = UISwipeGestureRecognizer(target: self,
        action: "swipeForNumber:")
      swipeUp.direction = .Up
      button?.addGestureRecognizer(swipeUp)
    }
  }
  
  func swipeForNumber(gesture: UISwipeGestureRecognizer) {
    if gesture.view!.tag == 10 {
      (textDocumentProxy as UIKeyInput).insertText("0")
    } else {
      let string = "\(gesture.view!.tag)"
      (textDocumentProxy as UIKeyInput).insertText(string)
    }
  }
}