import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    var accessToken: String? {
        get { KeychainWrapper.standard.string(forKey: "accessToken") }
        set { KeychainWrapper.standard.set(newValue ?? "", forKey: "accessToken") }
    }
}

