import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
    case invalidToken
    case decodingError
}

final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private let token = OAuth2TokenStorage().accessToken
    private init() {}
    private(set) var profile: Profile?
    
    private func makeProfileRequest(token: String)-> URLRequest? {
        guard let url = URL(string: Constants.unsplashMeURLString) else {
            print ("Invalid URL for request")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func profileFill(result: ProfileResult) -> Profile
    {
        let firstName = result.firstName ?? ""
        let lastName = result.lastName ?? ""
        let profile = Profile (
            userName: result.username,
            name: "\(firstName) \(lastName)",
            loginName: "@\(result.username)",
            bio: result.bio ?? "")
        return profile
    }
    
    func fetchProfileData (token: String, handler: @escaping (Result<Profile, Error>) -> Void)
    {
        assert(Thread.isMainThread)
        guard lastToken != token else {
            print("[ProfileService] Token hasn't changed, skipping request [token: \(token)]")
            handler(.failure(ProfileServiceError.invalidToken))
            return
        }
        task?.cancel()
        lastToken  = token
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService] Failed to create URLRequest")
            handler(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    self.profile = self.profileFill(result: result)
                    if let profile = self.profile {
                        handler(.success(profile)) } else {
                            print("[ProfileService] Failed to decode profile data")
                            handler(.failure(ProfileServiceError.decodingError))
                        }
                case .failure(let error):
                    print("[ProfileService] Failed to fetch profile data: \(error.localizedDescription) ")
                    handler(.failure(error))
                }
            }
            self.task = nil
            self.lastToken = nil
        }
        self.task = task
        task.resume()
    }
}
