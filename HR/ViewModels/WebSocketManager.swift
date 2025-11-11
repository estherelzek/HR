//
//  WebSocketManager.swift
//  HR
//
//  Created by Esther Elzek on 11/11/2025.
//

import Foundation

class WebSocketManager: NSObject {
    private var webSocketTask: URLSessionWebSocketTask?
    
    func connect() {
        let url = URL(string: "wss://your-server.com/realtime")!
        webSocketTask = URLSession(configuration: .default).webSocketTask(with: url)
        webSocketTask?.resume()
        listen()
    }
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("❌ WebSocket error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📨 Received update: \(text)")
                    // update UI or reload data
                default:
                    break
                }
            }
            self?.listen()
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
