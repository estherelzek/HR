//
//  Untitled.swift
//  HR
//
//  Created by Esther Elzek on 10/09/2025.
//

import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completion: ((CLLocationCoordinate2D?) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        self.completion = completion
        print("📍 LocationService.requestLocation called")
        
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            print("📍 Requesting whenInUseAuthorization")
            manager.requestWhenInUseAuthorization()
        } else if status == .denied || status == .restricted {
            print("❌ Location permission denied/restricted")
            completion(nil)
            return
        }
        
        // ✅ Try last known location first
        if let lastLocation = manager.location {
            print("📍 Using last known location")
            completion(lastLocation.coordinate)
            self.completion = nil
            return
        }
        
        print("📍 Calling manager.requestLocation()")
        manager.requestLocation()
    }

   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("📍 locationManager didUpdateLocations called")
        completion?(locations.first?.coordinate)
        completion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ locationManager didFailWithError: \(error.localizedDescription)")
        completion?(nil)
        completion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location authorized")
            manager.requestLocation()
        case .denied, .restricted:
            print("❌ Location permission denied/restricted by user")
            completion?(nil)
            completion = nil
        case .notDetermined:
            print("🔄 Location permission not determined yet")
        @unknown default:
            print("❓ Unknown location authorization status")
        }
    }
}
