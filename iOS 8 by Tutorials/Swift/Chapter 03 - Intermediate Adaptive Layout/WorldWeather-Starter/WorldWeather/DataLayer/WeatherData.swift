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

import Foundation

class WeatherData {
  private(set) var cities = [CityWeather]()
  
  init(plistNamed: String) {
    self.cities = loadWeatherData(plistNamed)
  }
  
  convenience init() {
    self.init(plistNamed: "WeatherData")
  }
  
  // MARK: - Private Methods
  private func loadWeatherData(plistNamed: String) -> [CityWeather] {
    let plistRoot = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource(plistNamed, ofType: "plist")!)
    var cityWeather = [CityWeather]()
    for (name, dailyWeather) in plistRoot as [String : [NSDictionary]] {
      cityWeather.append(CityWeather(array: dailyWeather, name: name))
    }
    return cityWeather
  }
}

extension CityWeather {
  private convenience init(array: [NSDictionary], name: String) {
    var dailyWeather = [DailyWeather]()
    for dict in array {
      dailyWeather.append(DailyWeather(dictionary: dict))
    }
    self.init(name: name, weather: dailyWeather)
  }
}

extension DailyWeather {
  private convenience init(dictionary: NSDictionary) {
    let status = WeatherStatus(dictionary: dictionary)
    self.init(date: dictionary["date"] as NSDate, status: status)
  }
}

extension WeatherStatus {
  private init(dictionary: NSDictionary) {
    let dictType = dictionary["type"] as String
    self.init(temperature: dictionary["temperature"] as Int, type: WeatherStatusType(rawValue: dictType)!)
  }
}
