//
//  FirebaseNetworkAccess.swift
//  Amanda's Recipes
//
//  Created by Ben Norris on 4/11/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import Foundation
//import Firebase

protocol Identifiable: Equatable {
    var id: String { get set }
}

func ==<T: Identifiable>(lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}


enum FirebaseError: Error {
    case nilUser
    case userRetrievalFailed(userId: String)
    case incorrectlyFormedData
}

struct FirebaseNetworkAccess {
    
    // MARK: - Properties
    
    let rootRef = FIRDatabase.database().reference()
    var core = App.core
    
    
    /// **root/users**
    var usersRef: FIRDatabaseReference {
        return rootRef.child("users")
    }
    
    /// **root/groups/{userId}**
    func groupsRef(userId: String) -> FIRDatabaseReference {
        return rootRef.child("groups").child(userId)
    }
    
    /// **root/students/{userId}
    func studentsRef(userId: String) -> FIRDatabaseReference {
        return rootRef.child("students").child(userId)
    }

    
    func setValue(at ref: FIRDatabaseReference, parameters: JSONObject, completion: ResultCompletion?) {
        ref.setValue(parameters) { error, ref in
            if let error = error {
                completion?(Result.error(error))
            } else {
                completion?(Result.ok(JSONObject()))
            }
        }
    }
    
    func createNewAutoChild(at ref: FIRDatabaseReference, parameters: JSONObject, completion: @escaping ResultCompletion) {
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
    
    func getData(at ref: FIRDatabaseReference, completion: ResultCompletion?) {
        ref.observeSingleEvent(of: .value, with: { snap in
            if let snapJSON = snap.value as? JSONObject , snap.exists() {
                completion?(Result.ok(snapJSON))
            } else {
                completion?(Result.error(FirebaseError.incorrectlyFormedData))
            }
        })
    }
    
    func getKeys(at ref: FIRDatabaseReference, completion: @escaping ((Result<[String]>) -> Void)) {
        ref.observeSingleEvent(of: FIRDataEventType.value, with: { snap in
            if let usernames = (snap.value as AnyObject).allKeys as? [String] , snap.exists() {
                completion(Result.ok(usernames))
            } else {
                completion(Result.error(FirebaseError.incorrectlyFormedData))
            }
        })
    }
    
    
    // Update
    
    func updateObject(at ref: FIRDatabaseReference, parameters: JSONObject, completion: ResultCompletion?) {
        ref.updateChildValues(parameters) { error, firebase in
            if let error = error {
                completion?(Result.error(error))
            } else {
                completion?(Result.ok(JSONObject()))
            }
        }
    }
    
    func addObject(at ref: FIRDatabaseReference, parameters: JSONObject, completion: ResultCompletion?) {
        ref.updateChildValues(parameters) { error, ref in
            if let error = error {
                completion?(Result.error(error))
            } else {
                completion?(Result.ok(JSONObject()))
            }
        }
    }
    
    
    // Delete
    
    func deleteObject(at ref: FIRDatabaseReference, completion: ResultCompletion?) {
        ref.removeValue { error, ref in
            if let error = error {
                completion?(Result.error(error))
            } else {
                completion?(Result.ok(JSONObject()))
            }
        }
    }
    
    
    // MARK: - Subscriptions
    
    func subscribe(to ref: FIRDatabaseReference, completion: @escaping ResultCompletion) {
        ref.observe(.value, with: { snap in
            if let snapJSON = snap.value as? JSONObject , snap.exists() {
                completion(Result.ok(snapJSON))
            } else {
                completion(Result.error(FirebaseError.incorrectlyFormedData))
            }
        })
    }
    
    func unsubscribe(from ref: FIRDatabaseReference) {
        ref.removeAllObservers()
    }
    
    
    // MARK: - Users
    
    func logInUser(with email: String, password: String) {
        self.setupAuthListener()
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { fUser, error in
            if let error = error {
                App.core.fire(event: ErrorEvent(error: error, message: error.firebaseAuthErrorMessage))
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
            core.fire(event: ErrorEvent(error: error, message: "Network error"))
        }
    }
    
}
