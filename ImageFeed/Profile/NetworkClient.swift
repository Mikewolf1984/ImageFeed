//
//  NetworkClient.swift
//  MovieQuiz
//
//

import Foundation

protocol NetworkClientProtocol {
    /// Запросить данные 
    func fetch(request : URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
}

/// Отвечает за загрузку данных по URL
struct NetworkClient: NetworkClientProtocol {
    
    private enum NetworkError: Error {
        case codeError(Int)
    }

    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем пришла ли ошибка
            if let error = error {
                handler(.failure(error))
                return
            }
        
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError(response.statusCode)))
                return
            }
            
            // Возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }

        task.resume()
    }
}
