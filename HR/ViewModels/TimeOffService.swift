//
//  TimeOffService.swift
//  HR
//
//  Created by Esther Elzek on 27/08/2025.
//

import Foundation

class TimeOffService {
    static let shared = TimeOffService()
    
    func getTimeOff(token: String, completion: @escaping (Result<TimeOffResponse, Error>) -> Void) {
        guard let url = URL(string: "https://your-api-url.com/timeoff") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode([String: TimeOffResponse].self, from: data)
                if let result = decoded["result"] {
                    completion(.success(result))
                } else {
                    let parseError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Parsing Error"])
                    completion(.failure(parseError))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
