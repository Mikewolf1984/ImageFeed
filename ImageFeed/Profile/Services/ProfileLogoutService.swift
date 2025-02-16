
import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService() 
    
    private init() { }
    
    func logout() {
        cleanCookies()
        ImagesListService.shared.clearImageListService()
        ProfileService.shared.clearProfileService()
        ProfileImageService.shared.clearProfileImageService()
        OAuth2TokenStorage.shared.deleteToken()
        switchToSplashController()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    private func switchToSplashController() {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        
        let logoutAction = UIAlertAction(title: "Да",
                                         style: .default) { _ in
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .default) { _ in
        }
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}

