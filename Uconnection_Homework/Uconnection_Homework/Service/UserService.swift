//
//  UserService.swift
//  Uconnection_Homework
//
//  Created by 전지훈 on 2021/11/01.
//

import Foundation
import Moya

enum UserService {
    case searchUser(name: String, page: Int)
}

extension UserService: TargetType {
    
    var baseURL: URL {
        let urlString = "https://api.github.com/"
        guard let url = URL(string: urlString) else { fatalError() }
        return url
    }
    
    var path: String {
        switch self {
        case .searchUser:
            return "search/users"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchUser:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .searchUser:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case .searchUser(let name, let page):
            return .requestParameters(parameters: ["q" : name, "page" : page, "per_page" : 20], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Typer" : "application/json"]
    }
    
    
}


