
@testable import ImageFeed
import UIKit
final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var notificationObserverCalled: Bool = false
    var isLiked: Bool = false
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func notificationObserver() {
        notificationObserverCalled = true
    }
    
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.isLiked = isLiked
            completion(.success(()))
        }
    }
}
