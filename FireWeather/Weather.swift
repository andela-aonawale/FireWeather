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
    var temperature: String
    var speed: Float
    var rain: Float
    
    init(weather: String, temperature: String, speed: Float, description: String, rain: Float){
        self.weather = weather
        self.temperature = temperature
        self.speed = speed
        self.rain = rain
    }
}