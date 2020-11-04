//
//  UserModel.swift
//  UsersList
//
//  Created by Тимофей Лукашевич on 4.11.20.
//

import UIKit

struct UserJsonModel: Decodable {
    var id: Int?
    var login: String?
    var avatar_url: String?
}



class User: Equatable {
    var id: Int
    var login: String
    var avatarImage: UIImage?
    
    init(userData: UserJsonModel) {
        self.id = userData.id ?? 0
        self.login = userData.login ?? ""
    }
    
    func setAvatarImage(_ image: UIImage) {
        self.avatarImage = image
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
