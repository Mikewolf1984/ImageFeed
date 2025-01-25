import UIKit


class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button") // 1
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button") // 2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "BackGroundColor") // 4
    }

 
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthentificatedWithCode code: String) {
        
        oauth2Service.fetchOAuthToken(code: code)
        
    }
    
    
}
