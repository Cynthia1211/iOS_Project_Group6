//
//  Users.swift
//  Project-Group6
//
//  Created by
//

import Foundation


class User {
    var uuid: String
    var nickname: String
    var score: Int
    
    init(uuid: String, nickname: String, score: Int = 0) {
        self.uuid = uuid
        self.nickname = nickname
        self.score = score
    }
}

// To be delete after SQLite include
struct UserMockData {
    static var sampleUsers: [User] = [
        User(uuid: "user_id_111", nickname: "Yue", score: 500),
        User(uuid: "user_id_222", nickname: "Alex", score: 350),
        User(uuid: "user_id_333", nickname: "Sophie", score: 200),
        User(uuid: "user_id_444", nickname: "Tram", score: 100),
        User(uuid: "user_id_555", nickname: "New Player", score: 0)
    ]
}
