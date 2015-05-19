//
//  Weather.swift
//  FireWeather
//
//  Created by Andela Developer on 5/13/15.
//  Copyright (c) 2015 Andela. All rights reserved.
//

import Foundation

class Weather {
    var weatherImage:String = ""
    var day:String = ""
    var minTemperature:String = ""
    var maxTemperature:String = ""
    
    init(weatherImage: String, day: String, minTemperature: String, maxTemperature: String){
        self.weatherImage = weatherImage
        self.day = day
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
    }
}