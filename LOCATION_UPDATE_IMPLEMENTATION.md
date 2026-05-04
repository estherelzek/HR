# Location Update Check Feature - Implementation Summary

## Overview
Added a new API integration that checks for location updates on app launch and updates the employee's stored location data if changes are detected.

## Files Created

### 1. **LocationUpdateResponse.swift**
- Path: `/HR/Models/LocationUpdateResponse.swift`
- Contains response models for the location update API:
  - `LocationUpdateResponse`: Main response structure with status, changed flag, company locations, and allowed location IDs
  - `LocationUpdateAPIResponse`: Wrapper for API responses

### 2. **LocationUpdateViewModel.swift**
- Path: `/HR/ViewModels/LocationUpdateViewModel.swift`
- Handles the business logic for checking and updating locations:
  - `checkLocationUpdates()`: Calls the API endpoint and processes the response
  - `updateEmployeeLocations()`: Updates UserDefaults with new location data
  - Posts `LocationsUpdated` notification when data changes

## Files Modified

### 1. **API.swift** (Network Layer)
- Added new case: `case checkLocationUpdates(token: String)`
- Added path: `/api/check_location_updates`
- Added body payload with employee token

### 2. **AppDelegate.swift**
- Added location update check in `didFinishLaunchingWithOptions`
- Runs automatically when the app launches
- Logs status of location update check

## Data Flow

1. **App Launch** → AppDelegate calls `LocationUpdateViewModel.checkLocationUpdates()`
2. **API Call** → Sends employee token to `/api/check_location_updates`
3. **Response Check** → If `changed: true`, locations are updated
4. **Update Storage** →
   - Updates `companyBranches` in UserDefaults
   - Updates `allowedBranchIDs` in UserDefaults
5. **Notification** → Posts `LocationsUpdated` notification for UI updates

## Data Structures

### Request
```json
{
  "employee_token": "string"
}
```

### Response (No Change)
```json
{
  "status": "success",
  "changed": false
}
```

### Response (With Changes)
```json
{
  "status": "success",
  "changed": true,
  "company_locations": [...],
  "allowed_locations_ids": [1, 2, 3]
}
```

## UserDefaults Keys Used
- `employeeToken`: Employee authentication token
- `companyBranches`: Encoded array of AllowedLocation objects
- `allowedBranchIDs`: Array of location IDs the employee can access

## Integration Points

The feature integrates with existing systems:
- Uses existing `NetworkManager` for API calls
- Uses existing `API` enum for endpoint management
- Uses existing UserDefaults extensions for data persistence
- Uses existing `AllowedLocation` model from LoginResponse.swift

## Error Handling
- Handles missing employee token gracefully
- Reports API failures without crashing the app
- Logs all operations for debugging

## Usage
The feature runs automatically on app launch. No manual integration needed in UI components, but they can observe the `LocationsUpdated` notification to refresh location-related data if needed.

Example observer in a ViewController:
```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(onLocationsUpdated),
    name: NSNotification.Name("LocationsUpdated"),
    object: nil
)
```
