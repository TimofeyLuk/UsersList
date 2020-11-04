//
//  ViewController.swift
//  UsersList
//
//  Created by Тимофей Лукашевич on 4.11.20.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var usersListTable: UITableView!
    var gitApiService = GitUsersService()
    var usersList:[User] = [] {
        didSet {
            if usersList.count == currentUsersCount && currentUsersCount != 0 {
                usersListTable.reloadData()
            }
        }
    }
    var currentUsersCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersListTable.delegate = self
        usersListTable.dataSource = self
        getUsersList()
    }
    
    func showConnectionFaildAllert() {
        let errorMessage = UIAlertController(title: "Application can't load data", message: "No internet connection, or you have reqest limit", preferredStyle: .alert)
        let reconnect = UIAlertAction(title: "reconnect", style: .cancel, handler: { (action) -> Void in
            self.getUsersList()
         })
        errorMessage.addAction(reconnect)
        self.present(errorMessage, animated: true, completion: nil)
    }
    
    
    // MARK: - Net functions
    
    func getUsersList() {
        gitApiService.getUsersList(completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                    case .success(let usersData):
                        if self.usersList.count == self.currentUsersCount {
                            self.currentUsersCount += usersData?.count ?? 0
                            self.setUsersData(usersData)
                        }
                    case .failure(let error):
                        if self.usersList.isEmpty {
                            print("Can't load users data with error:\n", error)
                            self.showConnectionFaildAllert()
                        }
                }
            }
        })
    }
    
    func setUsersData(_ usersData: [UserJsonModel]?) {
        guard let data = usersData else { return }
        var newUsersList:[User] = []
        for userInfo in data {
            let newUser = User(userData: userInfo)
            getUserImage(imageLink: userInfo.avatar_url ?? "", user: newUser)
            newUsersList.append(newUser)
        }
        newUsersList.sort(by: {$0.id < $1.id})
        gitApiService.lastId = newUsersList.last?.id ?? (gitApiService.lastId + newUsersList.count)
    }
    
    func getUserImage(imageLink: String, user: User) {
        gitApiService.getUserAvatarImage(imageLink: imageLink, completion: {  result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let usersAvatar):
                        let image = usersAvatar ?? UIImage(named: "defaultUserImage.jpg")!
                        user.setAvatarImage(image)
                        if  !self.usersList.contains(user) {
                            self.usersList.append(user)
                            self.usersList.sort(by: {$0.id < $1.id})
                        }
                    case .failure(let error):
                        print("Can't load image with error:\n", error)
                }
            }
        })
    }
    
    
    // MARK: - Table functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        
        if let userCell = cell as? UserTableCell {
            let user = usersList[indexPath.row]
            userCell.userIdLabel.text = "#\(user.id)"
            userCell.userNameLabel.text = user.login
            userCell.userAvatar.image = user.avatarImage ?? UIImage(named: "defaultUserImage.jpg")!
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == usersList.count {
            getUsersList()
        }
    }

}

