import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchOAuthToken (code: String, handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[fetchOAuthToken] Duplicate code received: [\(code)]")
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        guard let request = makeRequest(code: code) else {
            print("[fetchOAuthToken] Invalid request")
            handler(.failure((AuthServiceError.invalidRequest)))
            return
        }
        
        let task = urlSession.objectTask(for: request) {(result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    handler(.success(response.token))
                case .failure(let error):
                    print("[Oauth2Service] Fetch token failed: [\(error.localizedDescription)]")
                    handler(.failure(error))
                }
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequest(code: String)-> URLRequest? {
        guard var urlComponentsString = URLComponents(string: Constants.unsplashTokenURLString) else {
            print("urlComponents error")
            return nil
        }
        urlComponentsString.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")]
        guard let url = urlComponentsString.url else {
            print ("Invalid URL for request")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
