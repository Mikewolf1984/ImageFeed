import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    func fetchOAuthToken (code: String, handler: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeRequest(code: code) else {
            print("Error creating URLRequest")
            return
        }
        let dataTask  = URLSession.shared.data(for: request) { result in
            switch result {
            case .failure(let error):
                print("Error with dataTask creating: \(error)")
                handler(.failure(error))
            case .success(let data):
                do  {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    handler(.success(response.token))
                } catch {
                    handler(.failure(error))
                }
            }
        }
        dataTask.resume()
    }
    
    func makeRequest(code: String)-> URLRequest? {
        guard var urlComponentsString = URLComponents(string: "https://unsplash.com/oauth/token") else {
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
