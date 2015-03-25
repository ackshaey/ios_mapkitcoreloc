//
//  ViewController.swift
//  WhereAmI
//
//  Created by Ackshaey Singh on 3/24/15.
//  Copyright (c) 2015 Ackshaey Singh. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var compassLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    var locationManager: CLLocationManager?
    var geoCoder: CLGeocoder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let status = CLLocationManager.authorizationStatus()
        self.geoCoder = CLGeocoder()
        
        switch status {
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.distanceFilter = 5.0
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager?.startUpdatingLocation()
            self.locationManager?.startUpdatingHeading()
        case CLAuthorizationStatus.NotDetermined, CLAuthorizationStatus.Restricted, CLAuthorizationStatus.Denied:
            
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.requestWhenInUseAuthorization()
            
        default:
            break
        }
        
        let center = CLLocationCoordinate2D(latitude: 37.56776, longitude: -122.26312)
        let region = MKCoordinateRegionMakeWithDistance(center, 1000, 1000)
        self.map.region = region
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        let trueHeading = newHeading.trueHeading
        headingLabel.text = trueHeading.description
        
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            
            manager.startUpdatingLocation()
        case CLAuthorizationStatus.NotDetermined, CLAuthorizationStatus.Restricted, CLAuthorizationStatus.Denied:

            locationLabel.text = "Sorry. Please authorize the location service"
            manager.requestWhenInUseAuthorization()
            
        default:
            break
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        println(location.description)
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let center = CLLocationCoordinate2DMake(lat, lon)
//        let region = MKCoordinateRegionMakeWithDistance(center, 1000, 1000)
        self.map.setCenterCoordinate(center, animated: true)
        self.map.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        
        var compassText = ""
        
        if let floor = location.floor {
            compassText = ""
            compassText = compassText + "\nFloor: \(floor.level)\n"
        }
        
        compassText = compassText + "\nSpeed: \(location.speed)\n"
        
//        println(location.speed)
        
//        locationLabel.text = location.description
//        let speed = Int(location.speed)
//        let floor = Int(location.floor.level)
        
        self.compassLabel.text = compassText
        
        
        geoCoder?.reverseGeocodeLocation(location, completionHandler: { (locations, error) -> Void in
            if error != nil {
                println("An error occurred preventing getting location addresses")
                exit(-1)
            } else {
                assert(locations.count == 1, "Too many locations were returned")
//                println("\(locations[0])")
                var plLoc = locations[0] as CLPlacemark
                self.locationLabel.text = "\(plLoc.subThoroughfare) \(plLoc.thoroughfare)\n\(plLoc.locality)"
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

