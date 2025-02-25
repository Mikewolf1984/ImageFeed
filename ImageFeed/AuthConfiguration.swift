import Foundation

enum Constants {
    static let accessKey = "wqNDPMWr8Erd0IorYNe8VHvogGCV38wWVtPqnI4tsMc"
    static let secretKey = "Ql8p1qeesOBo_QDrfJkPIiVhnWZsgBeQC5FX5OI9krY"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
    static let unsplashUsersURLString = "https://api.unsplash.com/users/"
    static let unsplashMeURLString = "https://api.unsplash.com/me"
    static let photosString = "https://api.unsplash.com/photos"
}

struct AuthConfiguration {
    
    static var standard: AuthConfiguration {
           return AuthConfiguration(accessKey: Constants.accessKey,
                                    secretKey: Constants.secretKey,
                                    redirectURI: Constants.redirectURI,
                                    accessScope: Constants.accessScope,
                                    authURLString: Constants.unsplashAuthorizeURLString,
                                    defaultBaseURL: Constants.defaultBaseURL)
       }
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
