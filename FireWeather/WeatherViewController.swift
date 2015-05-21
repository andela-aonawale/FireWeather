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

class WeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let rootRef: Firebase = Firebase(url:"https://fireweather.firebaseio.com/")
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var containerView: UIView!
    var dropDownView: UITableView!
    var weatherArray = [Weather]()
    var cities: NSDictionary!
    var selectedCity: String = "calabar,ng"
    var showTable: Bool!
  
    //@IBOutlet weak var changeSelectedCity: UIButton!
    
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
        refreshWeatherForcast(self)
        createDropDown()
        showTable = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        // Read data and react to changes
        forecast()
    }
    
    @IBAction func refreshWeatherForcast(sender: AnyObject) {
        request(.GET, "http://fire-weather.herokuapp.com/api/v1/")
        .responseJSON{(request, response, data, error) in
            println(data)
        }
    }
    
    func forecast() {
        rootRef.observeEventType(.Value, withBlock: {
            snapshot in
            self.cities = snapshot.value!["cities"] as! NSDictionary
            self.dropDownView.reloadData()
            
            if let json = JSON(snapshot.value!) as JSON?{
                self.title = json["cities", self.selectedCity, "dailyForcast", "name"].stringValue
                self.weatherType.text = json["cities", self.selectedCity, "dailyForcast", "weather", 0, "description"].stringValue
                var temp = json["cities", self.selectedCity, "dailyForcast", "main", "temp"].double
                self.temperature.text = String(Int(round(temp!))) + "\u{00B0}"
                self.weatherImage.image = UIImage(named: json["cities", self.selectedCity, "dailyForcast", "weather", 0, "main"].stringValue)
                self.humidity.text = json["cities", self.selectedCity, "dailyForcast", "main", "humidity"].stringValue + "%"
                let rain = json["cities", self.selectedCity, "dailyForcast", "rain", "3h"].stringValue as String?
                if rain!.isEmpty {
                    self.rainfall.text = "0mm"
                }else {
                    self.rainfall.text = json["cities", self.selectedCity, "dailyForcast", "rain", "3h"].stringValue + "mm"
                }
                self.windSpeed.text = json["cities", self.selectedCity, "dailyForcast", "wind", "speed"].stringValue + "mph"
                self.setBackgroundColor(self.firstView, temperature: String(Int(round(json["cities", self.selectedCity, "dailyForcast", "main", "temp_min"].double!))))
                self.navigationController?.navigationBar.barTintColor = self.firstView.backgroundColor
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
                
                var jsonArray = json["cities", self.selectedCity, "5DaysForcast"] as JSON
                self.weatherArray = []
                for(var i=1; i<6; i++) {
                    var weather = Weather(weatherImage: jsonArray[i, "weather", "main"].stringValue,
                                        day: jsonArray[i, "day"].stringValue,
                                        minTemperature: jsonArray[i, "temperature", "min"].stringValue,
                                        maxTemperature: jsonArray[i, "temperature", "max"].stringValue)
                    self.weatherArray.append(weather)
                }
                self.createBottomViews()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBackgroundColor(myview: UIView, temperature: String) {
        var temp: Int = temperature.toInt()!
        if(temp < 18) {
            myview.backgroundColor = UIColor(red: 0/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
        }else if(temp < 23 && temp >= 18) {
            myview.backgroundColor = UIColor(red: 0/255.0, green: 102/255.0, blue: 0/255.0, alpha: 1.0)
        }else if(temp < 28 && temp >= 23) {
            myview.backgroundColor = UIColor(red: 71/255.0, green: 147/255.0, blue: 71/255.0, alpha: 1.0)
        }else if(temp < 33 && temp >= 28) {
            myview.backgroundColor = UIColor(red: 255/255.0, green: 173/255.0, blue: 92/255.0, alpha: 1.0)
        }else if(temp < 38 && temp >= 33) {
            myview.backgroundColor = UIColor(red: 255/255.0, green: 163/255.0, blue: 71/255.0, alpha: 1.0)
        }else if(temp < 43 && temp >= 38) {
            myview.backgroundColor = UIColor(red: 255/255.0, green: 153/255.0, blue: 0/255.0, alpha: 1.0)
        }else if(temp > 43) {
            myview.backgroundColor = UIColor(red: 230/255.0, green: 138/255.0, blue: 0/255.0, alpha: 1.0)
        }
    }
    
    // set bottom view text properties
    func setBottomViewLabel(label: UILabel, text: String, textColor: UIColor, fontName: String, fontSize: Int) {
        label.text = text
        label.textColor = textColor
        label.font = UIFont(name: fontName, size: CGFloat(fontSize))
    }
    
    // Create views for subsequent days and assign component values
    func createBottomViews() {
        for(var count:CGFloat = 0; count<5; count++) {
            var viewHeight:CGFloat = self.containerView.frame.size.height / 5
            let bottomView: UIView = UIView()
            bottomView.frame = CGRectMake(0, self.containerView.frame.origin.y + count * viewHeight, self.containerView.frame.size.width, self.containerView.frame.size.height / 5)
            setBackgroundColor(bottomView, temperature: weatherArray[Int(count)].minTemperature)
            self.view.addSubview(bottomView)
            
            let dayLabel: UILabel = UILabel()
            let minTempLabel: UILabel = UILabel()
            let maxTempLabel: UILabel = UILabel()
            let imageView: UIImageView = UIImageView()
            
            imageView.image = UIImage(named: weatherArray[Int(count)].weatherImage)
            setBottomViewLabel(dayLabel, text: (weatherArray[Int(count)].day), textColor: UIColor.whiteColor(), fontName: "AvenirNext-DemiBold", fontSize: 17)
            setBottomViewLabel(minTempLabel, text: (weatherArray[Int(count)].minTemperature + "\u{00B0}"), textColor: UIColor.whiteColor(), fontName: "AvenirNext-DemiBold", fontSize: 14)
            setBottomViewLabel(maxTempLabel, text: (" / " + weatherArray[Int(count)].maxTemperature + "\u{00B0}"), textColor: UIColor.whiteColor(), fontName: "AvenirNext-DemiBold", fontSize: 17)
            
            dayLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            minTempLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            maxTempLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            bottomView.addSubview(dayLabel)
            bottomView.addSubview(minTempLabel)
            bottomView.addSubview(maxTempLabel)
            bottomView.addSubview(imageView)

            var dayLabelConstraintX = NSLayoutConstraint(item: dayLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 8)
            var dayLabelConstraintY = NSLayoutConstraint(item: dayLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            bottomView.addConstraint(dayLabelConstraintX)
            bottomView.addConstraint(dayLabelConstraintY)
            
            var maxTempLabelConstraintX = NSLayoutConstraint(item: maxTempLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -10)
            var maxTempLabelConstraintY = NSLayoutConstraint(item: maxTempLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            bottomView.addConstraint(maxTempLabelConstraintX)
            bottomView.addConstraint(maxTempLabelConstraintY)
            
            var minTempLabelConstraintX = NSLayoutConstraint(item: minTempLabel, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: maxTempLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
            var minTempLabelConstraintY = NSLayoutConstraint(item: minTempLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            bottomView.addConstraint(minTempLabelConstraintX)
            bottomView.addConstraint(minTempLabelConstraintY)
            
            var imageViewConstraintX = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: minTempLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -10)
            var imageViewConstraintY = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            var imageViewContraintHeight = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.Height, multiplier: 0.75, constant: 0)
            var imageViewConstraintWidth = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
            bottomView.addConstraint(imageViewConstraintX)
            bottomView.addConstraint(imageViewConstraintY)
            bottomView.addConstraint(imageViewContraintHeight)
            bottomView.addConstraint(imageViewConstraintWidth)
        }
    }
    
    // Create drop down table view
    func createDropDown() {
        dropDownView = UITableView()
        setUITableViewDelegateAndDataSource(dropDownView)
        dropDownView.frame = CGRectMake(0, -getDropDownViewYPosition(), self.view.frame.size.width, getDropDownViewHeight())
        configureUITableView(dropDownView)
        self.view.addSubview(dropDownView)
    }
    
    // Return number of rows in the tableview
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = cities?.allKeys.count as Int?{
            return num
        }else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        let city: AnyObject = cities.allKeys[indexPath.row]
        configureUITableViewCell(cell, text: (city as? String)!, textColor: UIColor.whiteColor(), fontName: "AvenirNext-DemiBold", fontSize: 17, cellBackgroundColor: UIColor.grayColor(), cellSelectionStyle: UITableViewCellSelectionStyle.None)
        return cell
    }
    
    // configure tableview cell
    func configureUITableViewCell(cell: UITableViewCell, text: String, textColor: UIColor, fontName: String, fontSize: Int, cellBackgroundColor: UIColor, cellSelectionStyle: UITableViewCellSelectionStyle) {
        cell.backgroundColor = cellBackgroundColor
        cell.selectionStyle = cellSelectionStyle
        setUITableViewCellTextLabel(cell, text: text, textColor: textColor, fontName: fontName, fontSize: fontSize)
    }
    
    
    // set tableview cell properties
    func setUITableViewCellTextLabel(cell: UITableViewCell, text: String, textColor: UIColor, fontName: String, fontSize: Int) {
        cell.textLabel!.text = text
        cell.textLabel?.textColor = textColor
        cell.textLabel?.font = UIFont(name: fontName, size: CGFloat(fontSize))
    }
    
    // configure tableview properties
    func configureUITableView(table: UITableView) {
        setUITableViewRowHeightAndFooter(table, rowHeight: 40)
        setUITableViewUIColors(dropDownView, backgroundColor: UIColor.darkGrayColor(), separatorColor: UIColor.clearColor())
        table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // set tableview row height and table footer
    func setUITableViewRowHeightAndFooter(table: UITableView, rowHeight: CGFloat) {
        table.rowHeight = rowHeight
        table.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // set tableView background color ans separator color
    func setUITableViewUIColors(table: UITableView, backgroundColor: UIColor, separatorColor: UIColor) {
        table.backgroundColor = backgroundColor
        table.separatorColor = separatorColor
    }
    
    // set tableview delegate and datasource
    func setUITableViewDelegateAndDataSource(table: UITableView) {
        table.delegate = self
        table.dataSource = self
    }
    
    // get navigation bar heigth
    func getNavBarHeight() -> CGFloat {
        return self.navigationController!.navigationBar.frame.size.height
    }
    
    // get status bar heigth
    func getStatusBarHeight() -> CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.height
    }
    
    // get height of dropdown tableview
    func getDropDownViewHeight() -> CGFloat {
        return self.view.frame.height / 2.85
    }
    
    // get the Y position of dropdown tableview
    func getDropDownViewYPosition() -> CGFloat {
        return self.view.frame.height / 2.85 + getNavBarHeight() + getStatusBarHeight()
    }
    
    // show or hide dropdown tableview with slidein / slideout animation
    @IBAction func toggleDropDownView() {
        if showTable == true {
            UIView.animateWithDuration(0.5, animations: {
                self.dropDownView.frame = CGRectMake(0, -self.getDropDownViewYPosition(), self.view.frame.size.width, self.getDropDownViewHeight())
            })
            showTable = false
        }else {
            UIView.animateWithDuration(0.5, animations: {
                self.dropDownView.frame = CGRectMake(0, self.getNavBarHeight() + self.getStatusBarHeight(), self.view.frame.size.width, self.getDropDownViewHeight())
            })
            showTable = true
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        selectedCity = cell!.textLabel!.text!
        forecast()
        toggleDropDownView()
    }

}








