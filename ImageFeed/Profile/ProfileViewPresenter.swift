import UIKit

public protocol ProfileViewPresenterProtocol {
    
    var view: ProfileViewControllerProtocol? { get set }
    func notificationObserver()
    func viewDidLoad()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    private var profileImageServiceObserver: NSObjectProtocol?
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        notificationObserver()
        view?.loadProfile()
    }
    func notificationObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.view?.updateAvatar()
            }
    }
}
