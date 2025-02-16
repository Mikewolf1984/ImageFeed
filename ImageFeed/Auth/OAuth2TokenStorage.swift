import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    var accessToken: String? {
        get { KeychainWrapper.standard.string(forKey: "accessToken") }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: "accessToken")
            } else {
                KeychainWrapper.standard.removeObject(forKey: "accessToken")
            }
        }
    }
    func deleteToken() {
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        }
}

