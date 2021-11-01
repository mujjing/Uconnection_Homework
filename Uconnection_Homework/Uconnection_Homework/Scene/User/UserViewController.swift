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
    
    var pagingCount = 1
    var totalCountCheck = false
    var totalCount = 0
    var searchWord = ""
    
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
        
        //searchBar
        userSearchBar.delegate = self
        userSearchBar.becomeFirstResponder()
        
        //검색
        inputSearchText()
        
        //키보드 숨기기
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneKeyboardAction))
        view.addGestureRecognizer(tap)
    }
    
    @objc func doneKeyboardAction() {
        view.endEditing(true)
    }
}

//API Call
extension UserViewController {
    
    func getUserData(_ name: String) {
        self.pagingCount = 1
        userProvider.rx.request(.searchUser(name: name, page: pagingCount))
            .subscribe { [weak self] (result) in
                switch result {
                case .success(let response):
                    let responseData = response.data
                    do {
                        self?.userItem.removeAll()
                        let decoded = try JSONDecoder().decode(User.self, from: responseData)
                        if decoded.totalCount ?? 0 > 20 {
                            self?.totalCountCheck = true
                            self?.totalCount = decoded.totalCount ?? 0
                            self?.searchWord = name
                        }
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
    
    func getExtensionUserData(_ name: String, _ count: Int) {
        userProvider.rx.request(.searchUser(name: name, page: count))
            .subscribe { [weak self] (result) in
                switch result {
                case .success(let response):
                    let responseData = response.data
                    do {
                        let decoded = try JSONDecoder().decode(User.self, from: responseData)
                        for users in decoded.items ?? [] {
                            self?.userItem.append(users)
                        }
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
            let userData = userItem[indexPath.row]
            cell.userSetting(userData.avatarURL, userData.login)
        } else {
            cell.userSetting("", "데이터가 없습니다")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func createSpinerFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }
    
}

//searchBar
extension UserViewController: UISearchBarDelegate {
    
    func inputSearchText(){
        self.userSearchBar.rx.text.orEmpty
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { searchText in
                self.getUserData(searchText)
            })
            .disposed(by: disposeBag)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension UserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if userTableView.contentOffset.y > (userTableView.contentSize.height - userTableView.frame.size.height){
            if totalCountCheck {
                if self.totalCount / 20 >= self.pagingCount {
                    self.userTableView.tableFooterView = self.createSpinerFooterView()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.pagingCount += 1
                        self.getExtensionUserData(self.searchWord, self.pagingCount)
                        self.userTableView.tableFooterView = nil
                        self.userTableView.reloadData()
                    }
                } else {
                    self.userTableView.tableFooterView = nil
                }
            } else {
                self.userTableView.tableFooterView = nil
            }
        }
    }
}
