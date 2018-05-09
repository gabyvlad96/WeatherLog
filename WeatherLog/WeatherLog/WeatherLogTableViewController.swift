//
//  WeatherLogTableViewController.swift
//  WeatherLog
//
//  Created by Vlad Gabriel on 20/03/2018.
//  Copyright © 2018 FMI. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class WeatherLogTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var forecastData = [Weather]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
      
    }
    
    func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { completion($0?.first, $1) }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
        {
        
        let mylocation = locations[0] // in mylocation sunt memorate coordonatele din GPS
        
            //convertesc coordonatele in numele orasului
            geocode(latitude: mylocation.coordinate.latitude, longitude: mylocation.coordinate.longitude) { placemark, error in
                guard let placemark = placemark, error == nil else { return }
                // you should always update your UI in the main thread
                DispatchQueue.main.async {
                    //  update UI here
                   
                    print("city:",     placemark.locality ?? "")
                    self.updateWeatherForLocation(location: placemark.locality ?? "")
                }
            }
        
       //updateWeatherForLocation(location: "Bucharest")
        
            //afisez coordonatele obtionute prin GPS
        print("Coordonate: \(mylocation.coordinate.latitude) / \(mylocation.coordinate.longitude)")
    }
    
    


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty {
           updateWeatherForLocation(location: locationString)
        }
    }
    
    
    
    func updateWeatherForLocation (location: String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                        if let weatherData = results {
                            self.forecastData = weatherData
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                //afisez coordonatele reconvertite din numele orasului
                                print("COORDONATE: \(location.coordinate.latitude) / \(location.coordinate.longitude)")

                            }
                        }
                        
                    })
                }
            }
        }
    }
   

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return forecastData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let date = Calendar.current.date(byAdding: .day, value: section, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        return dateFormatter.string(from: date!)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let weatherObject = forecastData[indexPath.section]
        cell.textLabel?.text = weatherObject.summary
        cell.detailTextLabel?.text = "\(Int((weatherObject.temperature - 32) * 5 / 9 )) °C"
        cell.imageView?.image = UIImage(named: weatherObject.icon)
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
