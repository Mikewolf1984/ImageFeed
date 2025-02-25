
import Foundation


final class ImagesListService {
    
    private enum ImagesListServiceError: Error {
        case invalidRequest
    }
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    var lastLoadedPage: Int?
    private(set) var photos: [Photo] = []
    private var currentTask: URLSessionTask?
    private let urlSession = URLSession.shared
    private let oauthToken = OAuth2TokenStorage.shared.accessToken
    
    static let isoDateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter
    }()
    
    func clearImageListService()
    {
        lastLoadedPage = nil
        photos.removeAll()
    }
    
    func fetchPhotosNextPage() {
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotoRequest(page: nextPage, perPage: "10") else {
            print("[ImagesListService] Error creating URLRequest")
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoResultResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.lastLoadedPage = nextPage
                let newPhotos = self.convertResultToPhotos(result: response)
                let uniqueNewPhotos = newPhotos.filter {photo in
                    !self.photos.contains(where: {$0.id == photo.id})
                }
                self.photos.append(contentsOf: uniqueNewPhotos)
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            case .failure(let error):
                print("[ImagesListService] Error fetching photos: \(error.localizedDescription)")
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
            print("[ImagesListService] Error: Cannot create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    private func makePhotoIsLikedRequest(photoID: String, state: Bool) -> URLRequest? {
        let urlString = "\(Constants.photosString)/\(photoID)/like"
        guard let url = URL(string: urlString) else {
            print("[ImagesListService] Error: Cannot create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = state ? "POST" :"DELETE"
        guard let token = oauthToken else {
            print("[ImagesListService] Error: Invalid token")
            return nil
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let request = makePhotoIsLikedRequest(photoID: photoId, state: isLike) else {
            print("[ImagesListService] Error: Cannot create URLRequest")
            return
        }
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("[ImagesListService] Error: Data task error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }  else {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = newPhoto
                    completion(.success(()))
                } else {
                    print("[ImagesListService] Error: Photo not found")
                    completion(.failure(ImagesListServiceError.invalidRequest))
                }
            }
        }
        task.resume()
    }
}

