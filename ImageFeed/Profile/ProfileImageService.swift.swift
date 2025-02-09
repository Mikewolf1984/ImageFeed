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
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("error: \(error)")
                    handler(.failure(ProfileImageServiceError.invalidRequest))
                    
                }
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        print("Status code != 200")
                    }
                }
                if let data = data  {
                    do {
                        let result = try JSONDecoder().decode(ProfileImageResult.self, from: data)
                        let profileImage = result.imageUrl
                        self.profileImageUrl = profileImage.small
                        handler(.success(profileImage.small))
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": self.profileImageUrl])
                    } catch {
                        handler(.failure(ProfileServiceError.decodingError))
                    }
                }
                self.task = nil
                self.lastUserName = nil
            }
        }
        self.task = task
        task.resume()
    }
}
