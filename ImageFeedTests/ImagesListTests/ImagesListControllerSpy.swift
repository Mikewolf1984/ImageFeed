@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    
    var presenter: ImagesListViewPresenterProtocol?
    var tableViewUpdatesCalled: Bool =  false
    func updateTableViewAnimated() {
        tableViewUpdatesCalled = true
    }
}
