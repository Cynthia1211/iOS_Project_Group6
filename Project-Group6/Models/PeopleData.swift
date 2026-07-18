//
//  PeopleData.swift
//  Project-Group6
//
//  Created by Cena Nguyen on 2026-07-14.
//

import UIKit

class PeopleData: NSObject {
    
    var id: Int?
    var username: String?
    var dateofBirth: String?
    var email: String?
    var uuid: String?
    var score: Int? = 0
    
    func initWithData(theRow i: Int,theUsername u: String,theDateofBirth d: String, theEmail e: String, theUuid uu: String, theScore s: Int){
        id = i
        username = u
        dateofBirth = d
        email = e
        uuid = uu
        score = s
    }

}
