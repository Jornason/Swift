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

	//Toggle between different second hands
  @IBInspectable var enableClockSecondHand: Bool = false {
    didSet { updateLayerProperties() }
  }

	//Toggle between image background and color background
  @IBInspectable var enableColorBackground: Bool = false {
    didSet { updateLayerProperties() }
  }

  //Base color background layer
  var backgroundLayer: CAShapeLayer!
  @IBInspectable var backgroundLayerColor: UIColor = UIColor.lightGrayColor() { didSet { updateLayerProperties() }
  }

  //Image background layer
  var backgroundImageLayer: CALayer!
  @IBInspectable var backgroundImage: UIImage? {
    didSet  { updateLayerProperties() }
  }
	
  //Ring Layer - Circular style progress bar that ticks clockwise.
  var ringLayer: CAShapeLayer!
  @IBInspectable var ringThickness: CGFloat = 2.0
  @IBInspectable var ringColor: UIColor = UIColor.blueColor()
  @IBInspectable var ringProgress: CGFloat = 45.0/60 {
    didSet { updateLayerProperties() }
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
  
  @IBInspectable var lineWidth: CGFloat = 1.0
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  //What makes the clock ticky tick :]
  var timer = NSTimer()
  var currentTimeZone: String = "Asia/Singapore"

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  func commonInit() {
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
    createAnalogClock()
    
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
  
  //MARK: Image and background layering
  //The base circular layer.
  func layoutBackgroundLayer() {
    if backgroundLayer == nil { //1
    backgroundLayer = CAShapeLayer() //2
    layer.addSublayer(backgroundLayer) //3
    
    let rect = CGRectInset(bounds, lineWidth / 2.0,
    lineWidth / 2.0) //4
    let path = UIBezierPath(ovalInRect: rect) //5
    
    backgroundLayer.path = path.CGPath //6
    backgroundLayer.fillColor = backgroundLayerColor.CGColor //7
    backgroundLayer.lineWidth = lineWidth //8
    }
    backgroundLayer.frame = layer.bounds //9
  }
	
  //Creates the background image layer
  func layoutBackgroundImageLayer() {
    if backgroundImageLayer == nil {
      let maskLayer = CAShapeLayer() //1
      let dx = lineWidth + 3.0
      let insetBounds = CGRectInset(self.bounds, dx, dx)
      let innerPath = UIBezierPath(ovalInRect: insetBounds)
      maskLayer.path = innerPath.CGPath
      maskLayer.fillColor = UIColor.blackColor().CGColor
      maskLayer.frame = self.bounds
      layer.addSublayer(maskLayer)
      
      backgroundImageLayer = CAShapeLayer()
      backgroundImageLayer.mask = maskLayer //2
      backgroundImageLayer.frame = self.bounds
      backgroundImageLayer.contentsGravity = kCAGravityResizeAspectFill
      layer.addSublayer(backgroundImageLayer)
      }
    }
	
  //MARK: Analog Watch Layering
  //Creates the watch's seconds indicator in a cirular form.
  func layoutWatchRingLayer() {
    if ringProgress == 0 { //1
      if ringLayer != nil {
        ringLayer.strokeEnd = 0.0
      }
    }
    
    if ringLayer == nil{ //2
      ringLayer = CAShapeLayer()
      layer.addSublayer(ringLayer)
      let dx = ringThickness / 2.0
      let rect = CGRectInset(bounds, dx, dx)
      let path = UIBezierPath(ovalInRect: rect)
      ringLayer.transform = CATransform3DMakeRotation(CGFloat(-(M_PI/2)), 0, 0, 1) //3
      ringLayer.strokeColor = ringColor.CGColor
      ringLayer.path = path.CGPath
      ringLayer.fillColor = nil
      ringLayer.lineWidth = ringThickness
      ringLayer.strokeStart = 0.0
    }
    ringLayer.strokeEnd = ringProgress / 60.0  //4
    ringLayer.frame = layer.bounds
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

  //Creates the hour hand layer
  func layoutHourHandLayer() {
    if hourHandLayer == nil {
      hourHandLayer = createClockHand(CGPointMake(1.0, 1.0), handLength: 52.0, handWidth:12.0, handAlpha: 1.0, handColor: hourHandColor)
      layer.addSublayer(hourHandLayer)
    }
  }

  //MARK: didSet Property Observers
  func updateLayerProperties() {
    //Updates the ring progress.
    if ringLayer != nil {
      ringLayer.strokeEnd = ringProgress / 60.0
    }
    
    // If user toggles between second hand and ring progress  indicator
    if enableClockSecondHand == true {
      setHideSecondClockHand(false)
      setHideRingLayer(true)
    } else if enableClockSecondHand == false {
      setHideSecondClockHand(true)
      setHideRingLayer(false)
    } else {
      setHideRingLayer(true)
      setHideSecondClockHand(true)
    }

    //Handles toggling between color background and image background.
    if enableColorBackground == true {
      setHideImageBackground(true)
    } else {
      setHideImageBackground(false)
    }

    if backgroundLayer != nil {
      backgroundLayer.fillColor = backgroundLayerColor.CGColor
    }
    
    //Updates the image layer.
    if backgroundImageLayer != nil {
      if let image = backgroundImage {
        backgroundImageLayer.contents = image.CGImage
      }
    }
  }
	
  //MARK: Hide components of the watch
  //Hides image background layer
  func setHideImageBackground(willHide: Bool) {
    if backgroundImageLayer != nil {
      backgroundImageLayer.hidden = willHide
    }
  }
  
  //Hides the clock second hand
  func setHideSecondClockHand(willHide: Bool) {
    if secondHandLayer != nil {
      secondHandLayer.hidden = willHide
    }
  }
  
  //Hides the ring layer
  func setHideRingLayer(willHide: Bool) {
    if ringLayer != nil {
      ringLayer.hidden = willHide
    }
  }
  
  //MARK: Helper Methods
  //Helper function that creates clock hands of different length and sizes or what not!
  func createClockHand(anchorPoint: CGPoint, handLength: CGFloat, handWidth: CGFloat, handAlpha: CGFloat, handColor: UIColor) -> CAShapeLayer {
    let handLayer = CAShapeLayer()
    let path = UIBezierPath()
    path.moveToPoint(CGPointMake(1.0, handLength))
    path.addLineToPoint(CGPointMake(1.0, bounds.size.height / 2.0))
    handLayer.bounds = CGRectMake(0.0, 0.0, 1.0, bounds.size.height / 2.0)
    handLayer.anchorPoint = anchorPoint
    handLayer.position = CGPointMake(CGRectGetMidX(bounds),   CGRectGetMidY(bounds))
    handLayer.lineWidth = handWidth
    handLayer.opacity = Float(handAlpha)
    handLayer.strokeColor = handColor.CGColor
    handLayer.path = path.CGPath
    handLayer.lineCap = kCALineCapRound
    return handLayer
  }

  func grabDateComponents(dateString: String) -> [String] {
  let dateArray = dateString.componentsSeparatedByString(":")
                      return dateArray
  }
  
  //MARK: Starting and stoping time
  func startTimeWithTimeZone(timezone: String) {
    //Set the current time zone selected
    endTime()	//1
    currentTimeZone = timezone	//2
    timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "animateAnalogClock", userInfo: nil, repeats: true) //3
  }
	
  func endTime() {
    timer.invalidate()
  }
	
  //MARK: Methods to make watch tick
  //The stuff that makes the clock just tick
  func animateAnalogClock() {
    //Get today's time.
    let now = NSDate() //1
    //Create a date formatter, and set the time zone selected by the user.
    let dateFormatter = NSDateFormatter() //2
    dateFormatter.timeZone = NSTimeZone(name: currentTimeZone)//3
    dateFormatter.dateFormat = "hh:mm:ss"//4
    //Extract the hour, minute, and second from the date string
    let dateComponents = grabDateComponents(dateFormatter.stringFromDate(now))//5
    //Convert string to integers
                        //6
    let hours = dateComponents[0].toInt()
    let minutes = dateComponents[1].toInt()
    let seconds = dateComponents[2].toInt()
                        //7
    //Calculate percentage to rotate clock hands by.
    let minutesIntoDay = CGFloat(hours!) * 60.0 + CGFloat(minutes!)
    let pminutesIntoDay = CGFloat(minutesIntoDay) / (12.0 * 60.0)
    let minutesIntoHour = CGFloat(minutes!) / 60.0
    let secondsIntoMinute = CGFloat(seconds!) / 60.0
                        //8
    if enableClockSecondHand == true {
      if secondHandLayer != nil {
        secondHandLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 2.0) * secondsIntoMinute, 0, 0, 1)
      }
    } else {  //9
      if ringLayer != nil {
        ringProgress = CGFloat(seconds!)
      }
    }
      //10
      if minuteHandLayer != nil {
        minuteHandLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 2) * minutesIntoHour, 0, 0, 1)
      }
      //11
    if hourHandLayer != nil {
      hourHandLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 2) * pminutesIntoDay, 0, 0, 1)
    }
  }
}




