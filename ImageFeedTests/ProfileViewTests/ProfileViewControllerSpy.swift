import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var avatarLoaded = false
    var profileLoaded = false
    func updateAvatar()
    {
        avatarLoaded = true
    }
    func loadProfile ()
    {
        profileLoaded = true
    }
}
