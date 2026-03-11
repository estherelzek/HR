//
//  FavoritesManager.swift
//  HR
//
//  Created by Esther Elzek on 25/02/2026.
//

import Foundation

class FavoritesManager {

    static let shared = FavoritesManager()
    private init() {
        loadFavorites()
    }

    private let key = "savedFavorites"

    var favorites: [LunchProduct] = [] {
        didSet {
            saveFavorites()
        }
    }

    // MARK: - Persistence

    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Failed to save favorites:", error)
        }
    }

    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }

        do {
            favorites = try JSONDecoder().decode([LunchProduct].self, from: data)
        } catch {
            print("❌ Failed to load favorites:", error)
        }
    }

    // MARK: - Logic

    func isFavorite(_ item: LunchProduct) -> Bool {
        return favorites.contains(where: { $0.id == item.id })
    }

    func toggle(_ item: LunchProduct) {
        if let index = favorites.firstIndex(where: { $0.id == item.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(item)
        }
    }

    func remove(_ item: LunchProduct) {
        favorites.removeAll { $0.id == item.id }
    }

    func clearFavorites() {
        favorites.removeAll()
    }
}
