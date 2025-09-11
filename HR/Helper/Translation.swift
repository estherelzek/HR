//
//  Translation.swift
//  HR
//
//  Created by Esther Elzek on 07/09/2025.
//

import Foundation

func translateText(_ text: String, targetLang: String, completion: @escaping (String?) -> Void) {
    let apiKey = "YOUR_GOOGLE_API_KEY"
    let urlString = "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)"
    
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = [
        "q": text,
        "target": targetLang,
        "format": "text"
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataObj = json["data"] as? [String: Any],
           let translations = dataObj["translations"] as? [[String: Any]],
           let translatedText = translations.first?["translatedText"] as? String {
            completion(translatedText)
        } else {
            completion(nil)
        }
    }.resume()
}

