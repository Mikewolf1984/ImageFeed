import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
    case invalidToken
    case decodingError
    case invalidUserName
}

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUserName: String?
    private let token = OAuth2TokenStorage().accessToken
    private init() {}
    private(set) var profileImageUrl: String?
    
    func clearProfileImageService() {
        profileImageUrl = nil
    }
    
    private func makeProfileImageRequest(token: String, userName: String)-> URLRequest? {
        guard let url = URL(string: Constants.unsplashUsersURLString+userName) else {
            print ("Invalid URL for request")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfileImage (token: String, userName: String, handler: @escaping (Result<String, Error>) -> Void)
    {
        guard lastUserName != userName else {
            print("[ProfileImageService] Same userName requested]")
            handler(.failure(ProfileImageServiceError.invalidUserName))
            return
        }
        task?.cancel()
        lastUserName  = userName
        
        guard let request = makeProfileImageRequest(token: token, userName: userName) else {
            print("[ProfileImageService] Invalid URLRequest")
            handler(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileImageResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    self.profileImageUrl = result.imageUrl.small
                    if self.profileImageUrl != nil {
                        handler(.success(self.profileImageUrl ?? ""))
                        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": self.profileImageUrl])
                    } else {
                        print("[ProfileImageService] Error decoding image url [URL: nil]")
                        handler(.failure(ProfileImageServiceError.decodingError))
                    }
                    
                case .failure(let error):
                    print ("[ProfileImageService] Error fetching image url: [\(error.localizedDescription)]")
                    handler(.failure(error))
                }
                self.task = nil
                self.lastUserName = nil
            }
        }
        self.task = task
        task.resume()
    }
}
