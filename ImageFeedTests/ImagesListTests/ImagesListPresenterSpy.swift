
@testable import ImageFeed
import UIKit
final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidAppearCalled: Bool = false
    var notificationObserverCalled: Bool = false
    var isLiked: Bool = false
    func viewDidAppear() {
        viewDidAppearCalled = true
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
