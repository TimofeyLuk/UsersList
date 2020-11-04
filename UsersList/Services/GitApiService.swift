//
//  GitApiService.swift
//  UsersList
//
//  Created by Тимофей Лукашевич on 4.11.20.
//

import UIKit

class GitUsersService {
    
    var lastId: Int = 0
    
    func getUsersList (completion: @escaping (Result<[UserJsonModel]?, Error>) -> Void){
        
        let urlString = "https://api.github.com/users?since=\(lastId)"
        guard let url =  URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, responce, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                let usersData = try JSONDecoder().decode([UserJsonModel].self, from: data!)
                completion(.success(usersData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
        
    }
    
    func getUserAvatarImage(imageLink: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let url =  URL(string: imageLink) else { return }
        URLSession.shared.dataTask(with: url) { (data, responce, error) in
            if let error = error, data == nil {
                completion(.failure(error))
                return
            }
            
            let image = UIImage(data: data!)
            completion(.success(image))
            
        }.resume()
    }

}

