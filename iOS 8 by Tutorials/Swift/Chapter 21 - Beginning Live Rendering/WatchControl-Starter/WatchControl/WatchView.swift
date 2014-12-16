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


class WatchView: UIView {
  var enableClockSecondHand: Bool = false {
  didSet { updateLayerProperties() }
  }

  var enableColorBackground: Bool = false {
    didSet { updateLayerProperties() }
  }

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
    //Creates Analog clock
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
    //TODO: Implement
  }

  //Creates the background image layer
  func layoutBackgroundImageLayer() {
    //TODO: Implement
  }

  //MARK: Analog Watch Layering
  //Creates the watch's seconds indicator in a cirular form.
  func layoutWatchRingLayer() {
    //TODO: Implement
  }

  //Creates the second hand layer
  func layoutSecondHandLayer() {
    //TODO: Implement
  }

  //Creates the minute hand layer
  func layoutMinuteHandLayer() {
    //TODO: Implement
  }

  func layoutHourHandLayer() {
    //TODO: Implement
  }

  //MARK: didSet Property Observers
  func updateLayerProperties() {
    //TODO: Implement
  }

  //MARK: Hide components of the watch
  func setHideImageBackground(willHide: Bool) {
    //TODO: Implement
  }

  func setHideSecondClockHand(willHide: Bool) {
    //TODO: Implement
  }

  func setHideRingLayer(willHide: Bool) {
    //TODO: Implement
  }

  //MARK: Helper Methods
  //Insert here

  //MARK: Starting and stoping time
  func startTimeWithTimeZone(timezone: String) {
    //TODO: Implement
  }

  func endTime() {
    //TODO: Implement
  }

  //MARK: Methods to make watch tick
  //The stuff that makes the clock just tick
  func animateAnalogClock() {
    //TODO: Implement
  }
}




