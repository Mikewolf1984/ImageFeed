import UIKit

class AuthViewController: UIViewController {
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button") // 1
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button") // 2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "BackGroundColor") // 4
    }
}
