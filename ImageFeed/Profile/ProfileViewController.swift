import UIKit
import Foundation

final class ProfileViewController: UIViewController {
    private let profilePhoto = UIImage(named: "defaultProfilePhoto")
    private let profileName = "Екатерина Новикова"
    private let profileAccountName = "@ekaterina_nov"
    private let helloText = "Hello, world!"
    private let profileService = ProfileService.shared
    private let token = OAuth2TokenStorage().accessToken ?? ""
    
    func loadProfile() {
        profileService.fetchProfileData(token: token) { result in
            
                switch result {
                case .success(let profile):
                    print(profile)
                case .failure(let error):
                    print(error)
                }
            }
        print("End loading profile")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        
        let profileImage = UIImageView(image: profilePhoto ?? UIImage(systemName: "person.crop.circle.fill"))
        let profileNameLabel = UILabel()
        let profileNickNameLabel = UILabel()
        let helloLabel = UILabel()
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "Exit")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        view.addSubview(profileImage)
        view.addSubview(profileNameLabel)
        view.addSubview(profileNickNameLabel)
        view.addSubview(helloLabel)
        view.addSubview(exitButton)
        configureImageView(image: profileImage)
        configureTextLabel(label: profileNameLabel, text: profileName, anchor: profileImage, top: 8, leading: 0, fontSize: 23, fontColor: .white)
        configureTextLabel(label: profileNickNameLabel, text: profileAccountName, anchor: profileNameLabel, top: 8, leading: 0, fontSize: 13, fontColor: .gray)
        configureTextLabel(label: helloLabel, text: helloText, anchor: profileNickNameLabel, top: 8, leading: 0, fontSize: 13, fontColor: .white)
        configureExitButton(button: exitButton, anchor: profileImage)
    }
    
    private func configureImageView(image: UIImageView){
        image.translatesAutoresizingMaskIntoConstraints = false
        image.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 18).isActive = true
        image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        image.widthAnchor.constraint(equalToConstant: 70).isActive = true
        image.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    private func configureTextLabel(label: UILabel, text: String, anchor: UIView, top: CGFloat, leading: CGFloat, fontSize: CGFloat, fontColor: UIColor) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: anchor.leadingAnchor, constant: leading).isActive = true
        label.topAnchor.constraint(equalTo: anchor.bottomAnchor, constant: top).isActive = true
        label.text = text
        label.font = .systemFont(ofSize: fontSize)
        label.textColor = fontColor
    }
    
    private func configureExitButton(button: UIButton, anchor: UIView) {
        button.tintColor = UIColor(named: "exitColor")
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26).isActive = true
        button.centerYAnchor.constraint(equalTo: anchor.centerYAnchor).isActive = true
    }
    @objc
    private func didTapButton() {
     //TODO later
    }
    
}
