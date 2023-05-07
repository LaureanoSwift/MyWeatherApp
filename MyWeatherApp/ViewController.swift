//
//  ViewController.swift
//  MyWeatherApp
//
//  Created by Laureano Velasco on 26/04/2023.

import UIKit
import CoreLocation


class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var table: UITableView!
    var models = [DailyEntry]()
    var hourlyModels = [DataHour]()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var current: CurrentWeather?
    var currentPosition: LocationData?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Register 2 Custom Cells
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        table.backgroundColor = UIColor(red: 96/255.0, green: 158/255.0, blue: 224/255.0, alpha: 1.0)
        view.backgroundColor = UIColor(red: 96/255.0, green: 158/255.0, blue: 224/255.0, alpha: 1.0)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    //MARK: - Location
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil{
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        let weatherUrl = "https://api.weatherapi.com/v1/forecast.json?key=018f843b248640198e2170841230405&q=\(lat),\(long)&days=7&aqi=no&alerts=no"
        
        URLSession.shared.dataTask(with: URL(string: weatherUrl)!, completionHandler: { data, response, error in
            
            //Validation
            guard let data = data, error == nil else {
                print("Something went wrong")
                return
            }
            
            //Convert data to models/ some object
            
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch {
                print("error: \(error)")
            }
            
            guard let result = json else {
                return
            }
            
            let entries = result.forecast.forecastday
            
            self.models.append(contentsOf: entries)
            
            let currently = result.current
            self.current = currently
            
            let currentlyLocation = result.location
            self.currentPosition = currentlyLocation
            
            self.hourlyModels = result.forecast.forecastday[0].hour
            
            //Update user interface
            
            DispatchQueue.main.async {
                self.table.reloadData()
                
                self.table.tableHeaderView = self.createTableHeader()
            }
            
        }).resume()
    }
    
    func createTableHeader ( ) -> UIView {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width-40))
        
         headerView.backgroundColor = UIColor(red: 96/255.0, green: 158/255.0, blue: 224/255.0, alpha: 1.0)
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/3))
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(summaryLabel)
        
        tempLabel.textAlignment = .center
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        
        guard let actualPosition = self.currentPosition else {
            return UIView()
        }
        
        locationLabel.text = "\(actualPosition.name)"
        locationLabel.font = UIFont(name: "Helvetica-Bold", size: 26)
        
        guard let currentWeather = self.current else {
            return UIView()
        }
        
        tempLabel.text = "\(currentWeather.temp_c)°"
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        
        summaryLabel.text = self.current?.condition.text
        
        return headerView
    }
    
    //MARK: - Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            
            //1 cell that is collectiontableviewcell
            return 1
        }
        //return models count
        return models.count
    }
    
        //Hourly
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyModels)
            cell.backgroundColor = UIColor(red: 96/255.0, green: 158/255.0, blue: 224/255.0, alpha: 1.0)
            return cell
        }
        
        //Daily
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = UIColor(red: 96/255.0, green: 158/255.0, blue: 224/255.0, alpha: 1.0)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }


}


struct WeatherResponse: Codable {
    let location: LocationData
    let current: CurrentWeather
    let forecast: DailyForecast
    }

struct LocationData: Codable {
    
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tz_id: String
    let localtime_epoch: Int
    let localtime: String
    
}

struct CurrentWeather: Codable {
    
    let last_updated_epoch: Int
    let last_updated: String
    let temp_c: Float
    let temp_f: Float
    let is_day: Int
    let condition: CurrentCondition
    let wind_mph: Float
    let wind_kph: Float
    let wind_degree: Int
    let wind_dir: String
    let pressure_mb: Double
    let pressure_in: Float
    let precip_mm: Float
    let precip_in: Float
    let humidity: Int
    let cloud: Int
    let feelslike_c: Float
    let feelslike_f: Float
    let vis_km: Float
    let vis_miles: Float
    let uv: Float
    let gust_mph: Float
    let gust_kph: Float
}

struct CurrentCondition: Codable {
    let text: String
    let icon: String
    let code: Int
}

struct DailyForecast: Codable {
    let forecastday: [DailyEntry]
    
}

struct DailyEntry: Codable {
    let date: String
    let date_epoch: Int
    let day: DataDay
    let astro: DataAstro
    let hour: [DataHour]
}


struct DataDay: Codable {
    let maxtemp_c: Float
    let maxtemp_f: Float
    let mintemp_c: Float
    let mintemp_f: Float
    let avgtemp_c: Float
    let avgtemp_f: Float
    let maxwind_mph: Float
    let maxwind_kph: Float
    let totalprecip_mm: Float
    let totalprecip_in: Float
    let totalsnow_cm: Float
    let avgvis_km: Float
    let avgvis_miles: Float
    let avghumidity: Float
    let daily_will_it_rain: Int
    let daily_chance_of_rain: Int
    let daily_will_it_snow: Int
    let daily_chance_of_snow: Int
    let condition: CurrentCondition
    let uv: Float
}

struct DataAstro: Codable {
    let sunrise: String
    let sunset: String
    let moonrise: String
    let moonset: String
    let moon_phase: String
    let moon_illumination: String
    
}

struct DataHour: Codable {
    let time_epoch: Int
    let time: String
    let temp_c: Float
    let temp_f: Float
    let is_day: Int
    let condition: CurrentCondition
    let wind_mph: Float
    let wind_kph: Float
    let wind_degree: Int
    let wind_dir: String
    let pressure_mb: Float
    let pressure_in: Float
    let precip_mm: Float
    let precip_in: Float
    let humidity: Float
    let cloud: Int
    let feelslike_c: Float
    let feelslike_f: Float
    let windchill_c: Float
    let windchill_f: Float
    let heatindex_c: Float
    let heatindex_f: Float
    let dewpoint_c: Float
    let dewpoint_f: Float
    let will_it_rain: Int
    let chance_of_rain: Int
    let will_it_snow: Int
    let chance_of_snow: Int
    let vis_km: Float
    let vis_miles: Float
    let gust_mph: Float
    let gust_kph: Float
    let uv: Float
    
}






