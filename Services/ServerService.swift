//
//  ServerService.swift
//  ToDoListMVC
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import Foundation

protocol ServerServiceProtocol: AnyObject {
    func fetchToDoData(from urlString: String, completion: @escaping (ToDoAnswer?) -> Void)
}

class ServerService: NSObject, ServerServiceProtocol {
    
    private override init() {}
    
    public static var shared = ServerService()

    func fetchToDoData(from urlString: String, completion: @escaping (ToDoAnswer?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Проверяем наличие ошибок
            if let error = error {
                print("Error fetching data: \(error)")
                completion(nil)
                return
            }
            
            // Проверяем, есть ли данные
            guard let data = data else {
                print("No data received.")
                completion(nil)
                return
            }
            
            // Декодируем данные
            do {
                let decoder = JSONDecoder()
                let answer = try decoder.decode(ToDoAnswer.self, from: data)
                completion(answer)
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
}
