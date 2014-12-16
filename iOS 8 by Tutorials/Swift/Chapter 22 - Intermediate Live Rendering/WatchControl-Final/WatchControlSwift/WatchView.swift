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
import QuartzCore

@IBDesignable
class WatchView: UIView {
  
  //Toggles between analog or digital clock design
  @IBInspectable var enableAnalogDesign: Bool = true {
    didSet { updateLayerProperties() }
  }
  
  @IBInspectable var enableClockSecondHand: Bool = false {
    didSet { updateLayerProperties() }
  }

  @IBInspectable var enableColorBackground: Bool = false {
    didSet { updateLayerProperties() }
  }
  //Ring Layer - Circular style progress bar that ticks clockwise.
  var ringLayer: CAShapeLayer!
  @IBInspectable var ringThickness: CGFloat = 2.0
  @IBInspectable var ringColor: UIColor = UIColor.blueColor()
  @IBInspectable var ringProgress: CGFloat = 45.0/60 {
    didSet { updateLayerProperties() }
  }

  //Base color background layer
  var backgroundLayer: CAShapeLayer!
  @IBInspectable var backgroundLayerColor: UIColor = UIColor.lightGrayColor() {
    didSet { updateLayerProperties() }
  }
  @IBInspectable var lineWidth: CGFloat = 1.0
  
  var hourMinuteSecondLayer: CATextLayer!
  var ampmLayer: CATextLayer!
  var weekdayLayer: CATextLayer!
  
  //Image background layer
  var backgroundImageLayer: CALayer!
  @IBInspectable var backgroundImage: UIImage? {
    didSet  { updateLayerProperties() }
  }

  //Watch second "hand"
  var secondHandLayer: CAShapeLayer!
  @IBInspectable var secondHandColor: UIColor = UIColor.redColor()

  //Watch minute "hand"
  var minuteHandLayer: CAShapeLayer!
  @IBInspectable var minuteHandColor: UIColor = UIColor.whiteColor()

  //Watch hour "hand"
  var hourHandLayer: CAShapeLayer!
  @IBInspectable var hourHandColor: UIColor = UIColor.whiteColor()

  //What makes the clock ticky ticky :]
  var timer = NSTimer()
  var currentTimeZone: String = "Asia/Singapore"

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  func commonInit() {
    //Initialize whatever here.
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    createClockFace()
  }

  func createClockFace() {
    //First we create the base background layer.
    layoutBackgroundLayer()
    //Then we layout the background image if there is one.
    layoutBackgroundImageLayer()

    if enableAnalogDesign == true {
      createAnalogClock()
    } else {
      createDigitalClock()
    }

    //If we haven't changed any of the inspectable properties.
    updateLayerProperties()
  }

  func createAnalogClock() {
    //Lays out the minute hand.
    layoutMinuteHandLayer()
    //Lays out the hour hand.
    layoutHourHandLayer()
    
    if enableClockSecondHand == true {
      //Lays out the second hand.
      layoutSecondHandLayer()
    } else {
      //Next we lay out the ring indicator.
      layoutWatchRingLayer()
    }
  }

  func createDigitalClock() {
    layoutHourMinuteSecondText()
    layoutAmPmText()
    layoutWeekDayText()
  }
  
  //The base circular layer.
  func layoutBackgroundLayer() {
    if backgroundLayer == nil {
      backgroundLayer = CAShapeLayer()
      layer.addSublayer(backgroundLayer)
      
      let rect = CGRectInset(bounds, lineWidth / 2.0, lineWidth / 2.0)
      let path = UIBezierPath(ovalInRect: rect)
      
      backgroundLayer.path = path.CGPath
      backgroundLayer.fillColor = backgroundLayerColor.CGColor
      backgroundLayer.lineWidth = lineWidth
      backgroundLayer.strokeColor = UIColor(white: 0.5, alpha: 0.3).CGColor
    }
    backgroundLayer.frame = layer.bounds
  }

  //Creates the watch's seconds indicator in a cirular form.
  func layoutWatchRingLayer() {
    if ringProgress == 0 {
      if ringLayer != nil {
        ringLayer.strokeEnd = 0.0
      }
    }
    
    if ringLayer == nil {
      ringLayer = CAShapeLayer()
      let dx = ringThickness / 2.0
      let rect = CGRectInset(bounds, dx, dx)
      let path = UIBezierPath(ovalInRect: rect)
      ringLayer.transform = CATransform3DMakeRotation(CGFloat(-(M_PI/2)), 0, 0, 1)
      ringLayer.strokeColor = ringColor.CGColor
      ringLayer.path = path.CGPath;
      ringLayer.fillColor = nil;
      ringLayer.lineWidth = ringThickness
      layer.addSublayer(ringLayer)
    }
    
    ringLayer.frame = layer.bounds
  }

  //Creates the background image layer
  func layoutBackgroundImageLayer() {
    if backgroundImageLayer == nil {
      let maskLayer = CAShapeLayer()
      let dx = lineWidth + 3.0
      let insetBounds = CGRectInset(layer.bounds, dx, dx)
      let innerPath = UIBezierPath(ovalInRect: insetBounds)
      maskLayer.path = innerPath.CGPath
      maskLayer.fillColor = UIColor.blackColor().CGColor
      maskLayer.frame = layer.bounds
      layer.addSublayer(maskLayer)
      
      backgroundImageLayer = CAShapeLayer()
      backgroundImageLayer.mask = maskLayer
      backgroundImageLayer.contentsGravity = kCAGravityResizeAspectFill
      layer.addSublayer(backgroundImageLayer)
      backgroundImageLayer.frame = layer.bounds
    }
  }

  //Creates the second hand layer
  func layoutSecondHandLayer() {
    if secondHandLayer == nil {
      secondHandLayer = createClockHand(CGPointMake(1.0, 1.0), handLength: 20.0, handWidth: 4.0, handAlpha: 1.0, handColor: secondHandColor)
      layer.addSublayer(secondHandLayer)
    }
  }

  //Creates the minute hand layer
  func layoutMinuteHandLayer() {
    if minuteHandLayer == nil {
      minuteHandLayer = createClockHand(CGPointMake(1.0, 1.0), handLength: 26.0, handWidth: 12.0, handAlpha: 1.0, handColor: minuteHandColor)
      layer.addSublayer(minuteHandLayer)
                      }
  }

  func layoutHourHandLayer() {
    if hourHandLayer == nil {
      hourHandLayer = createClockHand(CGPointMake(1.0, 1.0), handLength: 65.0, handWidth:12.0, handAlpha: 1.0, handColor: hourHandColor)
      layer.addSublayer(hourHandLayer)
    }
  }

  func layoutHourMinuteSecondText() {
    if hourMinuteSecondLayer == nil {
    hourMinuteSecondLayer = createTextLayer("00:00:00", fontSize: bounds.size.height/8.5, offset: bounds.size.height/2.0)
    layer.addSublayer(hourMinuteSecondLayer)
    }
  }

  func layoutAmPmText() {
      if ampmLayer == nil {
      ampmLayer = createTextLayer("am", fontSize: (bounds.size.height/13.0), offset: bounds.size.height/1.6)
      layer.addSublayer(ampmLayer)
      }
  }

  func layoutWeekDayText() {
      if weekdayLayer == nil {
      weekdayLayer = createTextLayer("Thursday", fontSize: (bounds.size.height/13.0), offset: bounds.size.height)
      layer.addSublayer(weekdayLayer)
      }
  }

  //MARK: Property Observer Function
  func updateLayerProperties() {
    //Updates the ring progress.
    if ringLayer != nil {
      ringLayer.strokeEnd = ringProgress / 60.0
    }
    
    //Updates the image layer.
    if backgroundImageLayer != nil {
      if let image = backgroundImage {
        backgroundImageLayer.contents = image.CGImage
      }
    }
    
    if backgroundLayer != nil {
      backgroundLayer.fillColor = backgroundLayerColor.CGColor
    }
    
    // If user toggles between second hand and ring progress indicator
    // If user toggles between analog and digital, we want to hide the components
    if enableAnalogDesign == true { // 1
        setHideAnalogDesign(false) // 2
        setHideDigitalDesign(true) // 3
        
        // If user toggles between second hand and ring progress indicator
      if enableClockSecondHand == true { // 4
        setHideSecondClockHand(false)
        setHideRingLayer(true)
      } else if enableClockSecondHand == false {
        setHideSecondClockHand(true)
        setHideRingLayer(false)
      } else {
        setHideRingLayer(true)
        setHideSecondClockHand(true)
      }
    } else { // 5
      //Show digital design
      setHideDigitalDesign(false)
      setHideAnalogDesign(true)
    }
    
    //Handles toggling between color background and image background.
    if enableColorBackground == true {
      setHideImageBackground(true)
    } else {
      setHideImageBackground(false)
    }
  }

  //MARK: Hiding Components
  func setHideImageBackground(willHide: Bool) {
    if backgroundImageLayer != nil {
      backgroundImageLayer.hidden = willHide
    }
  }

  func setHideSecondClockHand(willHide: Bool) {
    if secondHandLayer != nil {
      secondHandLayer.hidden = willHide
    }
  }

  func setHideRingLayer(willHide: Bool) {
    if ringLayer != nil {
      ringLayer.hidden = willHide
    }
  }

  func setHideAnalogDesign(willHide: Bool) {
    if secondHandLayer != nil {
      secondHandLayer.hidden = willHide
    }
    if hourHandLayer != nil {
      hourHandLayer.hidden = willHide
    }
    if minuteHandLayer != nil {
      minuteHandLayer.hidden = willHide
    }
    if ringLayer != nil {
      ringLayer.hidden = willHide
    }
  }

  func setHideDigitalDesign(willHide: Bool) {
    if hourMinuteSecondLayer != nil {
      hourMinuteSecondLayer.hidden = willHide
    }
    if ampmLayer != nil {
      ampmLayer.hidden = willHide
    }
    if weekdayLayer != nil {
      weekdayLayer.hidden = willHide
    }
  }

  //MARK: Helper Methods
  //Helper function that creates clock hands of different length and sizes or what not!
  func createClockHand(anchorPoint: CGPoint, handLength: CGFloat, handWidth: CGFloat, handAlpha: CGFloat, handColor: UIColor) -> CAShapeLayer {
    let handLayer = CAShapeLayer()
    let path = UIBezierPath()
    path.moveToPoint(CGPointMake(1.0, handLength))
    path.addLineToPoint(CGPointMake(1.0, bounds.size.height / 2.0))
    handLayer.frame = CGRectMake(0.0, 0.0, 1.0, bounds.size.height / 2.0)
    handLayer.anchorPoint = anchorPoint
    handLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
    handLayer.lineWidth = handWidth
    handLayer.opacity = Float(handAlpha)
    handLayer.strokeColor = handColor.CGColor
    handLayer.path = path.CGPath
    handLayer.lineCap = kCALineCapRound
    handLayer.contentsScale = UIScreen.mainScreen().scale
    
    return handLayer
  }
  
  func createTextLayer(string: String, fontSize: CGFloat, offset: CGFloat) -> CATextLayer {
      let layer = CATextLayer() //1
      layer.font = UIFont(name: "HelveticaNeue-Light", size: fontSize) //2
      layer.fontSize = fontSize //3
      layer.frame = CGRectMake(0.0, 0.0, bounds.size.width/2.0,   bounds.size.height/2.0) //4
      layer.position = CGPointMake(CGRectGetMidX(bounds), offset) //5
      layer.string = string //6
      layer.alignmentMode = kCAAlignmentCenter //7
      layer.foregroundColor = UIColor.whiteColor().CGColor //8
      layer.contentsScale = UIScreen.mainScreen().scale //9
      return layer
  }

  //Splits date components seperated by ":"
  func grabDateComponents(dateString: String) -> [String] {
    let dateArray = dateString.componentsSeparatedByString(":")
    return dateArray
  }

  //MARK: Start and Stop Time Controls
  func startTimeWithTimeZone(timezone: String) {
      //Set the current time zone selected
      endTime()
      currentTimeZone = timezone
      if enableAnalogDesign == true {
      timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "animateAnalogClock", userInfo: nil, repeats: true)
    } else {
      timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "animateDigitalClock", userInfo: nil, repeats: true)
      }
  }

  func endTime() {
    timer.invalidate()
  }

  //The stuff that makes the clock just tick
  func animateAnalogClock() {
    //Get today's time.
    let now = NSDate()
    //Create a date formatter, and set the time zone selected by the user.
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeZone = NSTimeZone(name: currentTimeZone)
    dateFormatter.dateFormat = "hh:mm:ss"
    //Extract the hour, minute, and second from the date string
    let dateComponents = grabDateComponents(dateFormatter.stringFromDate(now))
    //Convert string to integers
    let hours = dateComponents[0].toInt()
    let minutes = dateComponents[1].toInt()
    let seconds = dateComponents[2].toInt()
    
    //Calculate percentage to rotate clock hands by.
    let minutesIntoDay = CGFloat(hours!) * 60.0 + CGFloat(minutes!);
    let pminutesIntoDay = CGFloat(minutesIntoDay) / (12.0 * 60.0)
    let minutesIntoHour = CGFloat(minutes!) / 60.0
    let secondsIntoMinute = CGFloat(seconds!) / 60.0
		
    if enableClockSecondHand == true {
      if secondHandLayer != nil {
        secondHandLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 2.0) * secondsIntoMinute, 0, 0, 1)
      }
    } else {
      if ringLayer != nil {
        ringProgress = CGFloat(seconds!)
      }
    }
    
    if minuteHandLayer != nil {
      minuteHandLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 2) * minutesIntoHour, 0, 0, 1)
    }
    
    if hourHandLayer != nil {
      hourHandLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 2) * pminutesIntoDay, 0, 0, 1)
    }
  }

  func animateDigitalClock() {
    //Get today's time.
    let now = NSDate() // 1
    //Create a date formatter, and set the time zone selected by the user.
    let dateFormatter = NSDateFormatter() //2
    dateFormatter.timeZone = NSTimeZone(name: currentTimeZone) //3
    dateFormatter.dateFormat = "hh:mm:ss:a:EEEE" //4
    //Extract the hour, minute, and second from the date string
    let dateComponents = grabDateComponents(dateFormatter.stringFromDate(now)) //5
    //Convert string to integers
    let hours = dateComponents[0].toInt() //6
    let minutes = dateComponents[1].toInt()
    let seconds = dateComponents[2].toInt()
    let ampm = dateComponents[3].lowercaseString
    let weekday = dateComponents[4]
    
    let hourminutesecondString = NSString(format: "%02ld:%02ld:%02ld", hours!, minutes!, seconds!) //7
    if let hmsLayer = hourMinuteSecondLayer { //8
      hmsLayer.string = hourminutesecondString
    }
    if let amPm = ampmLayer { //9
      amPm.string = ampm
    }
    if let week = weekdayLayer { //10
      week.string = weekday
    }
  }
  
  func copyClockSettings(clock: WatchView) {
    enableAnalogDesign = clock.enableAnalogDesign
    enableClockSecondHand = clock.enableClockSecondHand
    enableColorBackground = clock.enableColorBackground
    
    ringThickness = clock.ringThickness
    ringColor = clock.ringColor
    ringProgress = clock.ringProgress
    hourHandColor = clock.hourHandColor
    minuteHandColor = clock.minuteHandColor
    secondHandColor = clock.secondHandColor
    backgroundImage = clock.backgroundImage
    lineWidth = clock.lineWidth
    backgroundLayerColor = clock.backgroundLayerColor
    currentTimeZone = clock.currentTimeZone
  }

}




