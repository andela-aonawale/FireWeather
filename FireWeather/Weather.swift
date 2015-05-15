//
//  Weather.swift
//  FireWeather
//
//  Created by Andela Developer on 5/13/15.
//  Copyright (c) 2015 Andela. All rights reserved.
//

import Foundation

class Weather {
    var weather: String
    var dayTemperature: String
    var nightTemperature: String
    
    init(weather: String, dayTemperature: String, nightTemperature: String){
        self.weather = weather
        self.dayTemperature = dayTemperature
        self.nightTemperature = nightTemperature
    }
}