import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
    case invalidToken
}


final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private var profile: Profile?
    private let token = OAuth2TokenStorage().accessToken
    private init() {}
    
    private func makeProfileRequest(token: String)-> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print ("Invalid URL for request")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfileData (token: String, handler: @escaping (Result<Profile, Error>) -> Void)
    {
        assert(Thread.isMainThread)
        guard lastToken != token else {
            print("Invalid token")
            handler(.failure(ProfileServiceError.invalidToken))
            return
        }
        task?.cancel()
        lastToken  = token
        guard let request = makeProfileRequest(token: token) else {
            print ("Invalid URL for request")
            handler(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("error: \(error)")
                }
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data {
                    do {
                        print ("Data: \(data)")
                        let result = try JSONDecoder().decode(ProfileResult.self, from: data)
                        let profile = self.profileFill(result: result)
                        handler(.success(profile))
                    } catch {
                        handler(.failure(error))
                    }
                }
                self.task = nil
                self.lastToken = nil
            }
        }
        self.task = task
        task.resume()
    }
    func profileFill(result: ProfileResult) -> Profile
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
}
