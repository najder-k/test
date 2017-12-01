//
//  ViewController.swift
//  map-view-app
//
//  Created by Konrad Najder on 11/30/17.
//  Copyright © 2017 Konrad Najder. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var myLocationManager: CLLocationManager!
    
    private func initializeLocationManager() {
        if (CLLocationManager.locationServicesEnabled()) {
            myLocationManager = CLLocationManager()
            myLocationManager.delegate = self
            myLocationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        let coord = lastLocation.coordinate
        let delta = lastLocation.speed / 2500
        let span = MKCoordinateSpan(latitudeDelta: delta,longitudeDelta: delta)
        let region = MKCoordinateRegion(center: coord, span: span)
        mapView.setRegion(region, animated: true)
        
        let marker = MKPointAnnotation()
        marker.coordinate = lastLocation.coordinate
        mapView.addAnnotation(marker)
        
        let myGeocoder = CLGeocoder()
        myGeocoder.reverseGeocodeLocation(lastLocation) { (placemarks, error) in
            let firstPlacemark = placemarks?.first
            guard let pm = firstPlacemark else { return }
            let addressList: [String] = [pm.country, pm.locality, pm.subLocality, pm.thoroughfare, pm.postalCode, pm.subThoroughfare].flatMap { $0 }
            self.textField.text = addressList.joined(separator: ", ")
        }
    }


    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func startClicked(_ sender: Any) {
        startButton.isEnabled = false
        stopButton.isEnabled = true
        myLocationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    @IBAction func stopClicked(_ sender: Any) {
        startButton.isEnabled = true
        stopButton.isEnabled = false
        myLocationManager.stopUpdatingLocation()
        mapView.showsUserLocation = false
    }
    
    @IBAction func clearClicked(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.isEnabled = false
        
        initializeLocationManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

