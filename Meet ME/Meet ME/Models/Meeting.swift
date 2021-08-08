//
//  Meeting.swift
//  Meet ME
//
//  Created by Vlada on 31.12.2020.
//

import Foundation

struct Meeting: Codable {
    let id: String
    let name: String
    let owner: String
    let date: StartEnd
    let users: [UserMeeting]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case owner
        case date
        case users
    }
}


struct UserMeeting: Codable {
    var status: Int
    var user: String //phone
}

struct CreateMeeting: Codable {
    var name: String
    var date: StartEnd
    var users: [UserUser]
}

struct StartEnd: Codable {
    var start: Date
    var end: Date
}

struct FreeMeeting: Codable {
    var duration: Int
    var users: [UserUser]
    
    init(duration: Int, users: [String]) {
        self.duration = duration
        self.users = users.map({ (usr) in
            return UserUser(user: usr)
        })
    }
}

struct UserUser: Codable {
    var user: String
}

struct ResponseMeeting: Codable {
    let status: Int
}
