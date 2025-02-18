

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    
    func testProfileControllerCallsViewDidLoad() {
        //given
        
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    func testProfileControllerNotificationObserver () {
        //given
        
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.notificationObserver()
        
        XCTAssertTrue(presenter.notificationObserverCalled)
    }
    
    func testProfileIsLoaded () {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.loadProfile()
        
        XCTAssertTrue(viewController.profileLoaded)
    }
    
    func testAvatarIsLoaded () {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.updateAvatar()
        
        XCTAssertTrue(viewController.avatarLoaded)
    }
}
