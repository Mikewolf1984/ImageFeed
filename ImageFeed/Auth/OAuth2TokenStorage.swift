import Foundation

class OAuth2TokenStorage {
    var accessToken: String? {
        get {
            guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
                print("No access token found")
                return nil
            }
            return token
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "accessToken")
        }
    }
}

