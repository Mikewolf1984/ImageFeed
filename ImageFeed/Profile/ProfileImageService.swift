import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
    case invalidToken
    case decodingError
    case invaliUserName
}


final class ProfileImageService
{
    
    static let shared = ProfileImageService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUserName: String?
    private let token = OAuth2TokenStorage().accessToken
    private init() {}
    private(set) var profileImageUrl: String?
    
    private func makeProfileImageRequest(token: String, userName: String)-> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(userName)") else {
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
            handler(.failure(ProfileImageServiceError.invaliUserName))
            return
        }
        task?.cancel()
        lastUserName  = userName
        
        guard let request = makeProfileImageRequest(token: token, userName: userName) else {
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
                    } else {
                        handler(.failure(ProfileImageServiceError.decodingError))
                    }
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
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
