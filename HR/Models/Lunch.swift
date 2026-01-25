//
//  Lunch.swift
//  HR
//
//  Created by Esther Elzek on 20/01/2026.
//

import Foundation
struct ImageURLBuilder {

    static func build(_ relativePath: String) -> URL? {
        let baseURL =
            UserDefaults.standard.baseURL ??
            API.defaultBaseURL

        guard !baseURL.isEmpty else { return nil }

        let cleanBase = baseURL.hasSuffix("/")
            ? String(baseURL.dropLast())
            : baseURL

        return URL(string: cleanBase + relativePath)
    }
}

struct LunchProduct: Codable {
    let id: Int
    let name: String
    let description: String?
    let price: Double
    let currency: String?
    let currencySymbol: String?          // <- optional now
    let categoryId: Int
    let categoryName: String
    let supplierId: Int
    let supplierName: String

    let image_base64: String?                 // <- optional because API may send false
    let categoryImageUrl: String?

    let isNew: Bool
    var isFavorite: Bool

    // Custom decoding to handle image_url being Bool or String
    private enum CodingKeys: String, CodingKey {
        case id, name, description, price, currency, currencySymbol = "currency_symbol"
        case categoryId = "category_id", categoryName = "category_name"
        case supplierId = "supplier_id", supplierName = "supplier_name"
        case image_base64 = "image_base64", categoryImageUrl = "category_image_url"
        case isNew = "is_new", isFavorite = "is_favorite"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)
        currency = try container.decodeIfPresent(String.self, forKey: .currency)
        currencySymbol = try container.decodeIfPresent(String.self, forKey: .currencySymbol)
        categoryId = try container.decode(Int.self, forKey: .categoryId)
        categoryName = try container.decode(String.self, forKey: .categoryName)
        supplierId = try container.decode(Int.self, forKey: .supplierId)
        supplierName = try container.decode(String.self, forKey: .supplierName)
        categoryImageUrl = try container.decodeIfPresent(String.self, forKey: .categoryImageUrl)
        isNew = try container.decode(Bool.self, forKey: .isNew)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)

        // Handle imageUrl which can be String or Bool (false)
        if let urlString = try? container.decode(String.self, forKey: .image_base64) {
            image_base64 = urlString
        } else {
            image_base64 = nil
        }
    }
}


struct LunchProductsResult: Codable {
    let products: [LunchProduct]
    let count: Int
}

struct LunchCategory: Decodable, Identifiable {
    let id: Int
    let name: String
    let productCount: Int
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case productCount = "product_count"
        case imageURL = "image_url"
    }
}



struct LunchProductsResponse: Decodable {
    let success: Bool
    let products: [LunchProduct]
    let count: Int
}

struct LunchCategoriesResponse: Decodable {
    let success: Bool
    let categories: [LunchCategory]
    let count: Int
}


struct LunchSuppliersResponse: Decodable {
    let success: Bool
    let suppliers: [LunchSupplier]
    let count: Int
}

struct LunchSupplier: Decodable, Identifiable {
    let id: Int
    let name: String
    let email: String?
    let phone: String?
    let address: String?
    let city: String?
    let zipCode: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case address
        case city
        case zipCode = "zip_code"
    }
}



