//
//  LocationHelper.swift
//  GCI
//
//  Created by Anthony Chollet on 15/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    typealias GetLocationCompletionHandler = () -> Void
    
    static let shared: LocationHelper = {
        let instance = LocationHelper()
        return instance
    }()
    
    private var locationManager: CLLocationManager?
    private var getLocationCompletion: GetLocationCompletionHandler?
    var currentLocation: CLLocation?
    
    private override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    func refresh(_ location: @escaping GetLocationCompletionHandler) {
        self.getLocationCompletion = location
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
            return
        }
        
        self.refreshLocation()
    }
    
    private func refreshLocation() {
        if let date = currentLocation?.timestamp, date.timeIntervalSinceNow > Constant.API.Durations.fetchDelayLocalisation {
            self.locationManager?.startUpdatingLocation()
        } else if currentLocation == nil {
            self.locationManager?.startUpdatingLocation()
        } else {
            getLocationCompletion?()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locationManager?.stopUpdatingLocation()
        guard let location = locations.last else {
            return
        }
        #if DEBUG
        currentLocation = CLLocation(latitude: 47.319876, longitude: 5.060443)
        #else
        currentLocation = location
        #endif
        
        getLocationCompletion?()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            self.refreshLocation()
        default:
            break
        }
    }
}
