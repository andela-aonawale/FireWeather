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
    
    var dropDownView: UITableView!
    var cities: NSDictionary!
    var weatherArray = [Weather]()
    var showTable: Bool = false
    var selectedCity: String = "calabar,ng"
    
    @IBOutlet weak var weatherType: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var rainfall: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var windDirection: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refreshWeatherForcast(self)
        createDropDown()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        // Read data and react to changes
        forecast()
    }
    
    @IBAction func refreshWeatherForcast(sender: AnyObject) {
        request(.GET, "http://fire-weather.herokuapp.com/api/v1/")
        .responseJSON{(request, response, data, error) in
        }
    }
    
    // set navigation bar background and text color
    func setNavigationBarProperties() {
        self.navigationController?.navigationBar.barTintColor = firstView.backgroundColor
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
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
                self.setNavigationBarProperties()
                
                var jsonArray = json["cities", self.selectedCity, "5DaysForcast"] as JSON
                self.weatherArray = []
                for(var i=1; i<6; i++) {
                    var weather = Weather(weatherImage: jsonArray[i, "weather", "main"].stringValue, day: jsonArray[i, "day"].stringValue, minTemperature: jsonArray[i, "temperature", "min"].stringValue, maxTemperature: jsonArray[i, "temperature", "max"].stringValue)
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
            myview.backgroundColor = UIColor(red: 0/255.0, green: 51/255.0, blue: 102/255.0, alpha: 1.0)
        }else if(temp < 24 && temp >= 18) {
            myview.backgroundColor = UIColor(red: 25/255.0, green: 71/255.0, blue: 117/255.0, alpha: 1.0)
        }else if(temp < 28 && temp >= 24) {
            myview.backgroundColor = UIColor(red: 0/255.0, green: 102/255.0, blue: 153/255.0, alpha: 1.0)
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
    
    // set constrainst for labels X and Y position
    func setLayoutConstraint(bottomView: UIView, item: UILabel, attrX: NSLayoutAttribute, relatedBy: NSLayoutRelation, toItemX: UIView, attributeX: NSLayoutAttribute, multiplierX: CGFloat, constantX: CGFloat, attrY: NSLayoutAttribute, toItemY: UIView, attributeY: NSLayoutAttribute, multiplierY: CGFloat, constantY: CGFloat){
        bottomView.addConstraint(NSLayoutConstraint(item: item, attribute: attrX, relatedBy: relatedBy, toItem: toItemX, attribute: attributeX, multiplier: multiplierX, constant: constantX))
        bottomView.addConstraint(NSLayoutConstraint(item: item, attribute: attrY, relatedBy: relatedBy, toItem: toItemY, attribute: attributeY, multiplier: multiplierY, constant: constantY))
    }
    
    // set constrainst for imageView Y position and heigth
    func setLayoutConstraint(bottomView: UIView, image: UIImageView, attrY: NSLayoutAttribute, relatedBy: NSLayoutRelation, toItemY: UIView, attributeY: NSLayoutAttribute, multiplierY: CGFloat, constantY: CGFloat, attrHeight: NSLayoutAttribute, toItemHeight: UIView, attributeHeight: NSLayoutAttribute, multiplierHeight: CGFloat, constantHeight: CGFloat){
        bottomView.addConstraint(NSLayoutConstraint(item: image, attribute: attrY, relatedBy: relatedBy, toItem: toItemY, attribute: attributeY, multiplier: multiplierY, constant: constantY))
        bottomView.addConstraint(NSLayoutConstraint(item: image, attribute: attrHeight, relatedBy: relatedBy, toItem: toItemHeight, attribute: attributeHeight, multiplier: multiplierHeight, constant: constantHeight))
    }
    
    // set constrainst for imageView X position and width
    func setLayoutConstraint(bottomView: UIView, image: UIImageView, attrX: NSLayoutAttribute, relatedBy: NSLayoutRelation, toItemX: UILabel, attributeX: NSLayoutAttribute, multiplierX: CGFloat, constantX: CGFloat, attrWidth: NSLayoutAttribute, attributeWidth: NSLayoutAttribute, multiplierWidth: CGFloat, constantWidth: CGFloat){
        bottomView.addConstraint(NSLayoutConstraint(item: image, attribute: attrX, relatedBy: relatedBy, toItem: toItemX, attribute: attributeX, multiplier: multiplierX, constant: constantX))
        bottomView.addConstraint(NSLayoutConstraint(item: image, attribute: attrWidth, relatedBy: relatedBy, toItem: image, attribute: attributeWidth, multiplier: multiplierWidth, constant: constantWidth))
    }
    
    // set components TranslatesAutoresizingMaskIntoConstraints
    func setTranslatesAutoresizingMaskIntoConstraints(dayLabel: UILabel, minTempLabel: UILabel, maxTempLabel: UILabel, imageView: UIImageView) {
        dayLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        minTempLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        maxTempLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    // add bottom view components
    func addSubView(bottomView: UIView, dayLabel: UILabel, minTempLabel: UILabel, maxTempLabel: UILabel, imageView: UIImageView) {
        bottomView.addSubview(dayLabel)
        bottomView.addSubview(minTempLabel)
        bottomView.addSubview(maxTempLabel)
        bottomView.addSubview(imageView)
    }
    
    // get bottom view height
    func getBottomViewHeight() -> CGFloat {
        return containerView.frame.size.height / 5
    }
    
    // get container view width
    func getContainerViewWidth() -> CGFloat {
        return containerView.frame.size.width
    }
    
    // get container view Y position
    func getContainerViewYPosition() -> CGFloat {
        return containerView.frame.origin.y
    }
    
    // Create views for subsequent days and assign component values
    func createBottomViews() {
        for(var count:CGFloat = 0; count<5; count++) {
            let dayLabel: UILabel = UILabel()
            let minTempLabel: UILabel = UILabel()
            let maxTempLabel: UILabel = UILabel()
            let imageView: UIImageView = UIImageView()
            let bottomView: UIView = UIView()
            
            bottomView.frame = CGRectMake(0, getContainerViewYPosition() + count * getBottomViewHeight(), getContainerViewWidth(), getBottomViewHeight())
            setBackgroundColor(bottomView, temperature: weatherArray[Int(count)].minTemperature)
            
            self.view.addSubview(bottomView)
            
            imageView.image = UIImage(named: weatherArray[Int(count)].weatherImage)
            setBottomViewLabel(dayLabel, text: (weatherArray[Int(count)].day), textColor: UIColor.whiteColor(), fontName: "AvenirNext-DemiBold", fontSize: 17)
            setBottomViewLabel(minTempLabel, text: (weatherArray[Int(count)].minTemperature + "\u{00B0}"), textColor: UIColor.whiteColor(), fontName: "AvenirNext-DemiBold", fontSize: 14)
            setBottomViewLabel(maxTempLabel, text: (" / " + weatherArray[Int(count)].maxTemperature + "\u{00B0}"), textColor: UIColor.whiteColor(), fontName: "AvenirNext-DemiBold", fontSize: 17)
            
            // set TranslatesAutoresizingMaskIntoConstraints
            setTranslatesAutoresizingMaskIntoConstraints(dayLabel, minTempLabel: minTempLabel, maxTempLabel: maxTempLabel, imageView: imageView)
            
            // add sub views
            addSubView(bottomView, dayLabel: dayLabel, minTempLabel: minTempLabel, maxTempLabel: maxTempLabel, imageView: imageView)
            
            // set laout constraint for dayLabel
            setLayoutConstraint(bottomView, item: dayLabel, attrX: .Leading, relatedBy: .Equal, toItemX: bottomView, attributeX: .Leading, multiplierX: 1, constantX: 8, attrY: .CenterY, toItemY: bottomView, attributeY: .CenterY, multiplierY: 1, constantY: 0)
            
            // set layout constraint for maxTempLabel
            setLayoutConstraint(bottomView, item: maxTempLabel, attrX: .Trailing, relatedBy: .Equal, toItemX: bottomView, attributeX: .Trailing, multiplierX: 1, constantX: -10, attrY: .CenterY, toItemY: bottomView, attributeY: .CenterY, multiplierY: 1, constantY: 0)
            
            // set layout constraint for minTempLabel
            setLayoutConstraint(bottomView, item: minTempLabel, attrX: .Trailing, relatedBy: .Equal, toItemX: maxTempLabel, attributeX: .Leading, multiplierX: 1, constantX: 0, attrY: .CenterY, toItemY: bottomView, attributeY: .CenterY, multiplierY: 1, constantY: 0)
            
            // set layout constraint for imageView Y position and Height constraints
            setLayoutConstraint(bottomView, image: imageView, attrY: .CenterY, relatedBy: .Equal, toItemY: bottomView, attributeY: .CenterY, multiplierY: 1, constantY: 0, attrHeight: .Height, toItemHeight: bottomView, attributeHeight: .Height, multiplierHeight: 0.75, constantHeight: 0)
            
            // set layout constraint for imageView X position and Width constraints
            setLayoutConstraint(bottomView, image: imageView, attrX: .Trailing, relatedBy: .Equal, toItemX: minTempLabel, attributeX: .Leading, multiplierX: 1, constantX: -10, attrWidth: .Width, attributeWidth: .Height, multiplierWidth: 1, constantWidth: 0)
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
        if let numberOfCities = cities?.allKeys.count as Int?{
            return numberOfCities
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
        return getParentViewHeight() / 2.85
    }
    
    // get the Y position of dropdown tableview
    func getDropDownViewYPosition() -> CGFloat {
        return self.view.frame.height / 2.85 + getNavBarHeight() + getStatusBarHeight()
    }
    
    
    // get dropdown tableview position when hidden
    func getDropDownViewHiddenPosition() -> CGRect {
        return CGRectMake(0, -getDropDownViewYPosition(), getParentViewWidth(), getDropDownViewHeight())
    }
    
    // get dropdown tableview position when displayed
    func getDropDownViewDisplayedPosition() -> CGRect {
        return CGRectMake(0, getNavBarHeight() + getStatusBarHeight(), getParentViewWidth(), getDropDownViewHeight())
    }
    
    // get parent view width
    func getParentViewWidth() -> CGFloat {
        return self.view.frame.size.width
    }
    
    // get parent view height
    func getParentViewHeight() -> CGFloat {
        return self.view.frame.size.height
    }
    
    //hide dropdown tableview
    func hideDropDownView() {
        UIView.animateWithDuration(0.5, animations: {
            self.dropDownView.frame = self.getDropDownViewHiddenPosition()
            self.showTable = !self.showTable
        })
    }
    
    // show dropdown tableview
    func showDropDownView() {
        UIView.animateWithDuration(0.5, animations: {
            self.dropDownView.frame = self.getDropDownViewDisplayedPosition()
            self.showTable = !self.showTable
        })
    }
    
    // show or hide dropdown tableview with slidein / slideout animation
    @IBAction func toggleDropDownView() {
        showTable == true ? hideDropDownView() : showDropDownView()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        selectedCity = cell!.textLabel!.text!
        forecast()
        toggleDropDownView()
    }

}








