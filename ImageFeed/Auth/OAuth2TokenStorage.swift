import Foundation

class OAuth2TokenStorage {
    var accessToken: String {
        get {
            guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
                fatalError("No access token found")
            }
            return token
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "accessToken")
        }
    }
}

