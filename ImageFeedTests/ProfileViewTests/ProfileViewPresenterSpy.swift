
import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var notificationObserverCalled: Bool = false
    func notificationObserver()
    {
        notificationObserverCalled = true
    }
    func viewDidLoad()
    {
        viewDidLoadCalled = true
    }
}
