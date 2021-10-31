//
//  UserViewController.swift
//  Uconnection_Homework
//
//  Created by 전지훈 on 2021/10/31.
//

import UIKit
import Moya
import RxSwift
import RxCocoa

class UserViewController: UIViewController {

    @IBOutlet weak var userSearchBar: UISearchBar!
    @IBOutlet weak var userTableView: UITableView!
    
    let userProvider = MoyaProvider<UserService>()
    var userItem : [UserItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

}

//InitView
extension UserViewController {
    func initView() {
        
        //UINavigationBar Title
        title = "Search Users"
        
        //tableview
        userTableView.delegate = self
        userTableView.dataSource = self
        
        getUserData("mujjing")
    }
}

//API Call
extension UserViewController {
    
    func getUserData(_ name: String) {
        userProvider.rx.request(.searchUser(name: name))
            .subscribe { [weak self] (result) in
                switch result {
                case .success(let response):
                    let responseData = response.data
                    do {
                        self?.userItem.removeAll()
                        let decoded = try JSONDecoder().decode(User.self, from: responseData)
                        self?.userItem = decoded.items ?? []
                        self?.userTableView.reloadData()
                    } catch (let err) {
                        debugPrint("err : \(err)")
                    }
                case .error(let error):
                    debugPrint("error : \(error)")
                }
            }
            .disposed(by: disposeBag)
    }
    
}

//TableView Setting
extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userItem.count == 0 ? 1 : userItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserTableViewCell else {fatalError()}
        if userItem.count > 0 {
            let testUserData = userItem[indexPath.row]
            cell.userSetting(testUserData.avatarURL, testUserData.login)
        } else {
            cell.userSetting("", "데이터가 없습니다")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
