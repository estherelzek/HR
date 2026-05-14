import Foundation

struct AppStoreUpdateInfo {
    let appStoreVersion: String
    let appStoreURL: URL
}

final class AppStoreUpdateChecker {
    static let shared = AppStoreUpdateChecker()

    private init() {}

    func checkForUpdate(completion: @escaping (Result<AppStoreUpdateInfo?, Error>) -> Void) {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier,
              let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            completion(.success(nil))
            return
        }

        let escapedBundleIdentifier = bundleIdentifier.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? bundleIdentifier
        let lookupURLString = "https://itunes.apple.com/lookup?bundleId=\(escapedBundleIdentifier)"

        guard let url = URL(string: lookupURLString) else {
            completion(.success(nil))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.success(nil))
                return
            }

            do {
                let response = try JSONDecoder().decode(ITunesLookupResponse.self, from: data)
                guard let app = response.results.first,
                      let appStoreURL = URL(string: app.trackViewUrl) else {
                    completion(.success(nil))
                    return
                }

                let shouldUpdate = app.version.compare(currentVersion, options: .numeric) == .orderedDescending
                if shouldUpdate {
                    completion(.success(AppStoreUpdateInfo(appStoreVersion: app.version, appStoreURL: appStoreURL)))
                } else {
                    completion(.success(nil))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

private struct ITunesLookupResponse: Decodable {
    let results: [ITunesApp]
}

private struct ITunesApp: Decodable {
    let version: String
    let trackViewUrl: String
}