import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthentificationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initController()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oauth2TokenStorage.accessToken  {
            fetchProfile(token)
            switchToTabBarController()
            guard let userName = profileService.profile?.userName else {return}
            fetchProfileImage(token: token, userName: userName)
            
        } else {
            if let authViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController {
                authViewController.delegate = self
                authViewController.modalPresentationStyle = .fullScreen
                present(authViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    private func initController()
    {
        self.view.backgroundColor = UIColor(named: "BackGroundColor")
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imageView = UIImageView(image: UIImage(named: "launchImage"))
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthentificatedWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.fetchOAuthToken(code)
            guard let token = oauth2TokenStorage.accessToken else { return }
            fetchProfile(token)
            
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfileData(token: token) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let result):
                let userName = result.userName
                self.fetchProfileImage(token: token, userName: userName)
            case .failure:
                self.showAlert(vc: self, title: "Что-то пошло не так", message: "Не удалось войти в систему")
            }
        }
    }
    
    private func fetchProfileImage(token: String, userName: String) {
        UIBlockingProgressHUD.show()
        profileImageService.fetchProfileImage(token: token, userName: userName){ [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                showAlert(vc: self, title: "Что-то пошло не так", message: "Не удалось загрузить аватар")
            }
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let token):
                oauth2TokenStorage.accessToken = token
                self.switchToTabBarController()
            case .failure(let error):
                showAlert(vc: self, title: "Что-то пошло не так", message: "Не удалось получить токен: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func showAlert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
}
