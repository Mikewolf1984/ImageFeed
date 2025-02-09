import UIKit
import Foundation
import Kingfisher

final class ProfileViewController: UIViewController {
    private var profilePhoto = UIImage(named: "defaultProfilePhoto")
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var currentProfile = Profile(userName: "ekaterina_nov",
                                         name: "Екатерина Новикова",
                                         loginName: "@ekaterina_nov",
                                         bio: "Hello world!")
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func loadProfile() {
        guard let profile = profileService.profile else { return }
        self.currentProfile = profile
        guard let profileImageUrl = profileImageService.profileImageUrl else { return }
        
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
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar(avatarImageView: profileImage)
            }
        
        
        
        view.addSubview(profileImage)
        view.addSubview(profileNameLabel)
        view.addSubview(profileNickNameLabel)
        view.addSubview(helloLabel)
        view.addSubview(exitButton)
        updateAvatar(avatarImageView: profileImage)
        configureImageView(image: profileImage)
        configureTextLabel(label: profileNameLabel, text: currentProfile.name, anchor: profileImage, top: 8, leading: 0, fontSize: 23, fontColor: .white)
        configureTextLabel(label: profileNickNameLabel, text: currentProfile.loginName, anchor: profileNameLabel, top: 8, leading: 0, fontSize: 13, fontColor: .gray)
        configureTextLabel(label: helloLabel, text: currentProfile.bio, anchor: profileNickNameLabel, top: 8, leading: 0, fontSize: 13, fontColor: .white)
        configureExitButton(button: exitButton, anchor: profileImage)
    }
    
    private func updateAvatar(avatarImageView: UIImageView) {                                   // 8
        guard
            let profileImageURL = ProfileImageService.shared.profileImageUrl,
            let url = URL(string: profileImageURL)
        else { return }
        // TODO [Sprint 11] Обновить аватар, используя Kingfisher
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "placeholder.jpeg"),
                              options: [.processor(processor)]) { result in
            switch result {
            case .success(let value):
                print(value.image)
                print(value.cacheType)
                print(value.source)
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    private func configureImageView(image: UIImageView){
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 18).isActive = true
        image.topAnchor.constraint(equalTo: view.topAnchor, constant: 76).isActive = true
        image.widthAnchor.constraint(equalToConstant: 70).isActive = true
        image.heightAnchor.constraint(equalToConstant: 70).isActive = true
        updateAvatar(avatarImageView: image)
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
