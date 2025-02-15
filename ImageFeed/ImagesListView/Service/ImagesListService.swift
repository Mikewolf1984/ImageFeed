
import Foundation


final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private let urlSession = URLSession.shared
    
    static let isoDateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter
    }()
    
    func fetchPhotosNextPage() {
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotoRequest(page: nextPage, perPage: "10") else {
            print("Error creating URLRequest")
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoResultResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.lastLoadedPage = nextPage
                let newPhotos = self.convertResultToPhotos(result: response)
                //self.photos.append(contentsOf: newPhotos)
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            case .failure(let error):
                print("Error fetching photos: \(error.localizedDescription)")
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    private func convertResultToPhotos(result: [PhotoResult]) -> [Photo] {
        var photosData = [Photo]()
        var i = 0
        for resultItem in result {
            let photosDataItem = Photo(id: resultItem.id ?? "",
                                       size: CGSize(width: CGFloat(resultItem.width),
                                                    height: CGFloat(resultItem.height)),
                                       createdAt: ImagesListService.isoDateFormatter.date(from: resultItem.createdAt ?? ""),
                                       welcomeDescription: resultItem.description ?? "",
                                       thumbImageURL: resultItem.urls?.thumb ?? "",
                                       largeImageURL: resultItem.urls?.regular ?? "",
                                       isLiked: resultItem.likedByUser ?? false)
            photosData.append(photosDataItem)
            i += 1
        }
        return photosData
    }
    
    private func makePhotoRequest(page: Int, perPage: String) -> URLRequest? {
        var urlComponents = URLComponents()
        
        urlComponents.path = "photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "client_id", value: Constants.accessKey),
        ]
        
        guard let url = urlComponents.url(relativeTo: Constants.defaultBaseURL) else {
            assertionFailure("Error creating URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}

