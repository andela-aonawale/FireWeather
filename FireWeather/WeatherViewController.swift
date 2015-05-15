//
//  WeatherViewController.swift
//  FireWeather
//
//  Created by Andela Developer on 5/13/15.
//  Copyright (c) 2015 Andela. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var rainfall: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var windDirection: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getWeatherForcast()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeatherForcast() {
        request(.GET, "http://api.openweathermap.org/data/2.5/weather?q=Lagos,ng&units=metric")
        .responseJSON { (request, response, data, error) in
            let json = JSON(data!)
            println(json)
            self.weatherType.text = json["weather", 0, "description"].stringValue
            var temp = json["main", "temp"].double
            self.temperature.text = String(Int(round(temp!))) + "\u{00B0}"
            self.weatherImage.image = UIImage(named: json["weather", 0, "main"].stringValue)
            self.humidity.text = json["main", "humidity"].stringValue + "%"
            self.rainfall.text = json["rain"] ? json["rain", "3h"].stringValue + "mm" : "0mm"
            self.windSpeed.text = json["wind", "speed"].stringValue + "mph"
        }
    }
    

}
