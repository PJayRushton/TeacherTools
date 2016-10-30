//
//  FirebaseNetworkAccess.swift
//  Amanda's Recipes
//
//  Created by Ben Norris on 4/11/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import Foundation
import Firebase

enum FirebaseError: Error {
    case nilUser
    case userRetrievalFailed(userId: String)
    case incorrectlyFormedData
}

struct FirebaseNetworkAccess {
    
    // MARK: - Properties
    
    let storage = FIRStorage.storage()
    let rootRef = FIRDatabase.database().reference()
    var core = App.core
    
    
    /// **root/users**
    var usersRef: FIRDatabaseReference {
        return rootRef.child("users")
    }
    
    /// **root/directory**
    var directoryRef: FIRDatabaseReference {
        return rootRef.child("directory")
    }
    
    /// **root/documents/(wasatch/iosepa)**
    var documentsRef: FIRDatabaseReference {
        return rootRef.child("documents").child(TargetHelper.currentCompanyString)
    }
    
    /// **root/receipts/(wasatch/iosepa)**
    var receiptRef: FIRDatabaseReference {
        return rootRef.child("receipts")
    }
    
    /// **root/messages/
    var messagesRef: FIRDatabaseReference {
        return rootRef.child("messages")
    }
    
    /// **root/config/(wasatch/iosepa)**
    var configRef: FIRDatabaseReference {
        return rootRef.child("config").child(TargetHelper.currentCompanyString)
    }
    
    var rollsRef: FIRDatabaseReference {
        return rootRef.child("studentRolls")
    }
    
    /// **root/checklists**
    var checklistsRef: FIRDatabaseReference {
        return rootRef.child("checklists")
    }
    
    
    func setValue(atRef ref: FIRDatabaseReference, parameters: JSONObject, completion: ResultCompletion?) {
        ref.setValue(parameters) { error, ref in
            if let error = error {
                completion?(Result.error(error))
            } else {
                completion?(Result.ok(JSONObject()))
            }
        }
    }
    
    func createNewAutoChild(atRef ref: FIRDatabaseReference, parameters: JSONObject, completion: @escaping ResultCompletion) {
        ref.childByAutoId().setValue(parameters) { error, ref in
            if let error = error {
                completion(Result.error(error))
            } else {
                let responseJSON: JSONObject = ["ref": ref]
                completion(Result.ok(responseJSON))
            }
        }
    }
    
    
    // Retrieve
    
    func getData(atRef ref: FIRDatabaseReference, completion: ResultCompletion?) {
        ref.observeSingleEvent(of: .value, with: { snap in
            if let snapJSON = snap.value as? JSONObject , snap.exists() {
                completion?(Result.ok(snapJSON))
            } else {
                completion?(Result.error(FirebaseError.incorrectlyFormedData))
            }
        })
    }
    
    func getKeys(atRef ref: FIRDatabaseReference, completion: @escaping ((Result<[String]>) -> Void)) {
        ref.observeSingleEvent(of: FIRDataEventType.value, with: { snap in
            if let usernames = (snap.value as AnyObject).allKeys as? [String] , snap.exists() {
                completion(Result.ok(usernames))
            } else {
                completion(Result.error(FirebaseError.incorrectlyFormedData))
            }
        })
    }
    
    
    // Update
    
    func updateObject(atRef ref: FIRDatabaseReference, parameters: JSONObject, completion: ResultCompletion?) {
        ref.updateChildValues(parameters) { error, firebase in
            if let error = error {
                completion?(Result.error(error))
            } else {
                completion?(Result.ok(JSONObject()))
            }
        }
    }
    
    func addObject(atRef ref: FIRDatabaseReference, parameters: JSONObject, completion: ResultCompletion?) {
        ref.updateChildValues(parameters) { error, ref in
            if let error = error {
                completion?(Result.error(error))
            } else {
                completion?(Result.ok(JSONObject()))
            }
        }
    }
    
    
    // Delete
    
    func deleteObject(atRef ref: FIRDatabaseReference, completion: ResultCompletion?) {
        ref.removeValue { error, ref in
            if let error = error {
                completion?(Result.error(error))
            } else {
                completion?(Result.ok(JSONObject()))
            }
        }
    }
    
    
    // MARK: - Subscriptions
    
    func subscribe(toRef ref: FIRDatabaseReference, completion: @escaping ResultCompletion) {
        ref.observe(.value, with: { snap in
            if let snapJSON = snap.value as? JSONObject , snap.exists() {
                completion(Result.ok(snapJSON))
            } else {
                completion(Result.error(FirebaseError.incorrectlyFormedData))
            }
        })
    }
    
    func unsubscribe(toRef ref: FIRDatabaseReference) {
        ref.removeAllObservers()
    }
    
    
    // MARK: - Users
    
    func logInUser(with email: String, password: String) {
        self.setupAuthListener()
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { fUser, error in
            if let error = error {
                App.core.fire(event: DisplayErrorMessage(error: error, message: error.firebaseAuthErrorMessage))
            } else if let user = fUser {
                App.core.fire(event: UserIdentified(userId: user.uid))
            }
        }
    }
    
    func setupAuthListener() {
        FIRAuth.auth()?.addStateDidChangeListener { fAuth, fUser in
            if let user = fUser {
                self.core.fire(event: UserIdentified(userId: user.uid))
            } else if fAuth.currentUser == nil {
                self.core.fire(event: UserIdentified(userId: nil))
            } else {
                self.core.fire(event: DisplayMessage(message: "Something went wrong. . . I'm sorry"))
            }
        }
    }
    
    func logOut() {
        do {
            try FIRAuth.auth()?.signOut()
            core.fire(event: UserLoggedOut())
        } catch {
            print(error)
            core.fire(event: DisplayErrorMessage(error: error, message: "Network error"))
        }
    }
    
}
