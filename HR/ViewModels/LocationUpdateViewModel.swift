//
//  LocationUpdateViewModel.swift
//  HR
//
//  Created by Esther Elzek on 05/05/2026.
//

import Foundation

final class LocationUpdateViewModel {
    
    // MARK: - Check Location Updates
    func checkLocationUpdates(completion: @escaping (Result<Bool, Error>) -> Void) {
        // Get employee token from UserDefaults
        guard let empToken = UserDefaults.standard.employeeToken else {
            print("❌ No employee token found for location update check")
            completion(.failure(APIError.requestFailed("No employee token")))
            return
        }
        
        print("🔍 Checking for location updates...")
        
        let endpoint = API.checkLocationUpdates(token: empToken)
        
        NetworkManager.shared.requestDecodable(endpoint, as: LocationUpdateResponse.self) { result in
            switch result {
            case .success(let response):
                guard let result = response.result else {
                    print("❌ Location update check failed: No result in response")
                    completion(.failure(APIError.requestFailed("No result in response")))
                    return
                }
                
                print("✅ Location update check successful")
                print("Status: \(result.status)")
                print("Changed: \(result.changed)")
                
                if result.changed {
                    print("🔄 Locations have changed! Updating employee data...")
                    self.updateEmployeeLocations(
                        locations: result.companyLocations,
                        allowedIDs: result.allowedLocationsIds
                    )
                    completion(.success(true))
                } else {
                    print("✅ No location changes")
                    completion(.success(false))
                }
                
            case .failure(let error):
                print("❌ Location update check failed: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Update Employee Locations
    private func updateEmployeeLocations(locations: [Company]?, allowedIDs: [Int]?) {
        // Update company branches if provided
        if let locations = locations {
            let branches: [AllowedLocation] = locations.compactMap { comp in
                guard let addr = comp.address,
                      let id = addr.id,
                      let lat = addr.latitude,
                      let lng = addr.longitude,
                      let allowed = addr.allowedDistance else { return nil }
                return AllowedLocation(id: id, latitude: lat, longitude: lng, allowedDistance: allowed)
            }
            
            if let encoded = try? JSONEncoder().encode(branches) {
                UserDefaults.standard.set(encoded, forKey: "companyBranches")
                print("🏢 Updated company branches: \(branches.map { $0.id })")
            }
        }
        
        // Update allowed location IDs if provided
        if let allowedIDs = allowedIDs {
            UserDefaults.standard.allowedBranchIDs = allowedIDs
            print("🟦 Updated allowed branches: \(allowedIDs)")
        }
        
        // Post notification that locations have been updated
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("LocationsUpdated"), object: nil)
        }
    }
}
