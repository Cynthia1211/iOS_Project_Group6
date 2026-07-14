//
//  AppDelegate.swift
//  Project-Group6
//
//  Created by Cena Nguyen on 2026-07-02.
//

import UIKit
import FirebaseCore
import SQLite3
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var currentUsername: String = ""
    var currentEmail: String = ""
    var currentDateOfBirth: String = ""

    var window: UIWindow?
    var databaseName  : String? = "project-group6.db"
    var databasePath :  String?
    var people : [PeopleData] = []
    
    func insertIntoDatabase(person: PeopleData) -> Bool {
        var db : OpaquePointer? = nil
        var returnCode : Bool = true
        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            var insertStatement : OpaquePointer? = nil
            var insertStatementString : String = "INSERT INTO entries VALUES (NULL, ?, ?, ?)"
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK{
                let username = person.username! as NSString
                let dateofBirth = person.dateofBirth! as NSString
                let email = person.email! as NSString
                
                sqlite3_bind_text(insertStatement, 1, username.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 2, dateofBirth.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 3, email.utf8String, -1, nil)
                
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    let rowID = sqlite3_last_insert_rowid(db)
                    print("successfully inserted row at \(rowID)")
                }
                else{
                    print("could not insert row")
                    returnCode = false
                }
                
                sqlite3_finalize(insertStatement)
            }
            else{
                print("insert statement could not be prepared")
                returnCode = false
            }
            sqlite3_close(db)
        }
        else{
            print("unable to open database")
            returnCode = false
        }
        return returnCode
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDir = documentPaths[0]
        databasePath = documentsDir.appending("/" + databaseName!)
        
        checkAndCreateDatabase()
        readDataFromDatabase()
        
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }
    func checkAndCreateDatabase() {
        
        var success = false
        let fileManager = FileManager.default
        
        success = fileManager.fileExists(atPath: databasePath!)
        
        if success { return }
        let databasePathFromApp = Bundle.main.resourcePath?.appending("/" + databaseName!)
        
        try? fileManager.copyItem(atPath: databasePathFromApp!, toPath: databasePath!)
    }
    func readDataFromDatabase() {
        
        people.removeAll()
        var db : OpaquePointer? = nil
        if sqlite3_open(databasePath, &db) == SQLITE_OK{
            print("successfully opened database at \(databasePath)")
            
            var queryStatement: OpaquePointer? = nil
            var queryStatementString = "SELECT * FROM entries"
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id : Int = Int(sqlite3_column_int(queryStatement, 0))
                    let cusername = sqlite3_column_text(queryStatement,1)
                    let cdateofBirth = sqlite3_column_text(queryStatement,2)
                    let cemail = sqlite3_column_text(queryStatement,3)
                    
                    let username = String(cString: cusername!)
                    let dateofBirth = String(cString: cdateofBirth!)
                    let email = String(cString: cemail!)
                    
                    let data : PeopleData = .init()
                    data.initWithData(theRow: id, theUsername: username, theDateofBirth: dateofBirth, theEmail: email)
                    people.append(data)
                    print("Querry Result")
                    print("\(id) | \(username) | \(dateofBirth) | \(email)")
                }
                    sqlite3_finalize(queryStatement)
                    
                } else{
                    print("select statement could not be prepared")
                }
                sqlite3_close(db)
                
            }
            else{
                print("unable to open database")
            }
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

