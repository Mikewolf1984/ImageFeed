import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    public func fetchOAuthToken (code: String, handler: @escaping (Result<String, Error>) -> Void) {
        guard var urlComponentsString = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("urlComponents error")
            return
        }
        urlComponentsString.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")]
        guard let url = urlComponentsString.url else {
            print ("Invalid URL for request")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let dataTask  = URLSession.shared.data(for: request) { result in
            switch result {
            case .failure(let error):
                print("Error with dataTask creating: \(error)")
                handler(.failure(error))
            case .success(let data):
                do  {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    print ("Token response successfully decoded: \(response.token)")
                    handler(.success(response.token))
                }
                catch {
                    print("Token decode error: \(error)")
                    handler(.failure(error))
                }
            }
        }
        dataTask.resume()
    }
}
