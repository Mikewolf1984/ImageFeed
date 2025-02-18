@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    
    func testImagesListViewDidLoad() {
        
        //Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        presenter.view = viewController
        viewController.presenter = presenter
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testChangeLike() {
        //Given
        let expect = XCTestExpectation(description: "Change like")
        let presenter = ImagesListViewPresenterSpy()
        
        //When
        presenter.changeLike(photoId: "PhotoId", isLiked: true) { _ in
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
        
        //Then
        XCTAssertTrue(presenter.isLiked)
    }
    
    func testUpdateTableViewAnimated() {
        //Given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenterSpy()
        presenter.view = viewController
        viewController.presenter = presenter
        
        //When
        viewController.updateTableViewAnimated()
        
        //Then
        XCTAssertTrue(viewController.tableViewUpdatesCalled)
    }
    
    func testImagesListNotificationObserver() {
        //Given
        let viewController = ImagesListViewController()
        let presenter = ImagesListViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        presenter.notificationObserver()
        
        //Then
        XCTAssertTrue(presenter.notificationObserverCalled)
    }
}
