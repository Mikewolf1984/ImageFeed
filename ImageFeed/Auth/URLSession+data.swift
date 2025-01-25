import Foundation

enum NetworkError: Error {  // 1
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in  // 2
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data)) // 3
                } else {
                    print(String(data: data, encoding: .utf8) ?? "Error in unwrapping data")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode))) // 4
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error))) // 5
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError)) // 6
            }
        })
        
        return task
    }
}
