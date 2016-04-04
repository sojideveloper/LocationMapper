//
//  LocationMapViewController.swift
//  LocationMapper
//
//  Created by iwritecode on 4/2/16.
//  Copyright © 2016 sojiwritescode. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationMapViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var currentLocationSwitch: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var showButton: UIButton!
    
    // MARK: - Properties
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var useCurrentLocation: Bool!
    var lastInputLocation = CLLocationCoordinate2D()
    var pin = MKPointAnnotation()
    
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addStyles()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        checkLocationType()
        
    }
    
    // MARK: - IBActions
    
    @IBAction func switchPressed(sender: UISwitch) {
        checkLocationType()
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        
        locationTextField.resignFirstResponder()
        
        // if useCurrentLocation == true || locationTextField.text == "" {

        if useCurrentLocation == true {
            showCurrentLocation()
        } else {
            if locationTextField.text != "" {
                showInputLocation(locationTextField.text!)
            } else {
                let title = "Error: Missing Input"
                let message = "Please enter a valid address or use your current location."
                showAlert(title: title, message: message)
            }
        }
    }
    
    
    // MARK: - Location Methods
    
    func checkLocationType() {
        if currentLocationSwitch.on {
            switchLabel.text = "Yes"
            switchLabel.textColor = UIColor.greenColor()
            useCurrentLocation = true
            locationTextField.hidden = true
        } else {
            switchLabel.text = "No"
            switchLabel.textColor = UIColor.redColor()
            useCurrentLocation = false
            locationTextField.hidden = false
        }
    }
    
    func showCurrentLocation() {
        if let location = locationManager.location {
            let coordinates = location.coordinate
            let latitude = coordinates.latitude
            let longitude = coordinates.longitude
            
            showLocationOnMap(latitude, longitude: longitude)
        }
    }
    
    func showInputLocation(address: String) {
        
        mapView.removeAnnotation(pin)
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemark = placemarks?.last {
                if let coordinates = placemark.location?.coordinate {
                    print("\n\nCoordinates ARE: \(coordinates)\n\n")
                    let latitude = coordinates.latitude
                    let longitude = coordinates.longitude
                    self.showLocationOnMap(latitude, longitude: longitude)
                }
            } else {
                let title = "Error: Invalid Location"
                let message = "Could not geocode location. Please verify the address or try a different one."
                self.showAlert(title: title, message: message)
            }
        }
    }
    
    // MARK: - Map methods...
    
    func showLocationOnMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
        
        addAnnotation(center)
    }
    
    func addAnnotation(center: CLLocationCoordinate2D) {
        mapView.removeAnnotation(pin)
        if !useCurrentLocation {
            pin.coordinate = center
            mapView.addAnnotation(pin)
        }
    }
    
    
    // MARK: - UI Markup
    
    func addStyles() {
        showButton.layer.cornerRadius = 30.0
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        locationTextField.resignFirstResponder()
    }
    
    func showAlert(title title: String, message: String) {
        
        let buttonTitle = "OK"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let buttonAction = UIAlertAction(title: buttonTitle, style: .Cancel, handler: nil)
        alert.addAction(buttonAction)
        self.presentViewController(alert, animated: true,completion: nil)
    }
    
}

// MARK: - CLLocationManagerDelegate

extension LocationMapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: \(error.localizedDescription)")
    }
    
}

// MARK: - UITextFieldDelegate

extension LocationMapViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

