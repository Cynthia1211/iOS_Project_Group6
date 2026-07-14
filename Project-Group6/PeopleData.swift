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
    
    func initWithData(theRow i: Int,theUsername u: String,theDateofBirth d: String, theEmail e: String){
        id = i
        username = u
        dateofBirth = d
        email = e
        
    }

}
