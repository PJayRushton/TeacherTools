//
//  FirebaseNetworkAccess.swift
//  Amanda's Recipes
//
//  Created by Ben Norris on 4/11/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import Foundation
import Firebase
import Marshal

struct NoOp: Event { }
protocol Identifiable: Equatable, JSONMarshaling, Unmarshaling {
    var id: String { get set }
    var ref: DatabaseReference { get }
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
    
    static let sharedInstance = FirebaseNetworkAccess()
    
    // MARK: - Properties
    
    let rootRef = Database.database().reference()
    var core = App.core
    
    
    /// **root/users**
    var usersRef: DatabaseReference {
        return rootRef.child("users")
    }
    
    /// **root/groups/{userId}**
    func groupsRef(userId: String) -> DatabaseReference {
        return rootRef.child("groups").child(userId)
    }
    
    /// **root/students/{userId}
    func studentsRef(userId: String) -> DatabaseReference {
        return rootRef.child("students").child(userId)
    }

    var allThemesRef: DatabaseReference {
        return rootRef.child("allThemes")
    }
    
    func setValue(at ref: DatabaseReference, parameters: JSONObject, completion: ResultCompletion?) {
        ref.setValue(parameters) { error, ref in
            if let error = error {
                completion?(Result.failure(error))
            } else {
                completion?(Result.success(JSONObject()))
            }
        }
    }
    
    func createNewAutoChild(at ref: DatabaseReference, parameters: JSONObject, completion: @escaping ResultCompletion) {
        ref.childByAutoId().setValue(parameters) { error, ref in
            if let error = error {
                completion(Result.failure(error))
            } else {
                let responseJSON: JSONObject = ["ref": ref]
                completion(Result.success(responseJSON))
            }
        }
    }
    
    
    // Retrieve
    
    func getData(at ref: DatabaseReference, completion: ResultCompletion?) {
        ref.observeSingleEvent(of: .value, with: { snap in
            if let snapJSON = snap.value as? JSONObject , snap.exists() {
                completion?(Result.success(snapJSON))
            } else {
                completion?(Result.failure(FirebaseError.incorrectlyFormedData))
            }
        })
    }
    
    func getData(withQuery query: DatabaseQuery, completion: ResultCompletion?) {
        query.observeSingleEvent(of: .value, with: { snap in
            if let json = snap.value as? JSONObject {
                completion?(.success(json))
            } else {
                completion?(.failure(FirebaseError.incorrectlyFormedData))
            }
        })
    }
    
    func getKeys(at ref: DatabaseReference, completion: @escaping ((Result<[String]>) -> Void)) {
        ref.observeSingleEvent(of: DataEventType.value, with: { snap in
            if let usernames = (snap.value as AnyObject).allKeys as? [String] , snap.exists() {
                completion(Result.success(usernames))
            } else {
                completion(Result.failure(FirebaseError.incorrectlyFormedData))
            }
        })
    }
    
    
    // Update
    
    func updateObject(at ref: DatabaseReference, parameters: JSONObject, completion: ResultCompletion?) {
        ref.updateChildValues(parameters) { error, firebase in
            if let error = error {
                completion?(Result.failure(error))
            } else {
                completion?(Result.success(JSONObject()))
            }
        }
    }
    
    func addObject(at ref: DatabaseReference, parameters: JSONObject, completion: ResultCompletion?) {
        ref.updateChildValues(parameters) { error, ref in
            if let error = error {
                completion?(Result.failure(error))
            } else {
                completion?(Result.success(JSONObject()))
            }
        }
    }
    
    
    // Delete
    
    func deleteObject(at ref: DatabaseReference, completion: ResultCompletion?) {
        ref.removeValue { error, ref in
            if let error = error {
                completion?(Result.failure(error))
            } else {
                completion?(Result.success(JSONObject()))
            }
        }
    }
    
    
    // MARK: - Subscriptions
    
    func subscribe(to ref: DatabaseReference, completion: @escaping ResultCompletion) {
        ref.observe(.value, with: { snap in
            if let snapJSON = snap.value as? JSONObject, snap.exists() {
                completion(Result.success(snapJSON))
            } else {
                completion(Result.failure(FirebaseError.incorrectlyFormedData))
            }
        })
    }
    
//    func fullySubscribe(to ref: DatabaseReference, completion: @escaping ((Result<JSONObject>, DataEventType) -> Void)) {
//        for eventType in [DataEventType.childAdded, .childChanged, .childRemoved] {
//            ref.observe(eventType, with: { snap in
//                if snap.exists(), let snapJSON = snap.value as? JSONObject {
//                    completion(Result.success(snapJSON), eventType)
//                } else {
//                    completion(Result.failure(FirebaseError.incorrectlyFormedData), eventType)
//                }
//            })
//        }
//    }
//
//    func fullySubscribe(to query: DatabaseQuery, completion: @escaping ((Result<JSONObject>, DataEventType) -> Void)) {
//        for eventType in [DataEventType.childAdded, .childChanged, .childRemoved] {
//            query.observe(eventType, with: { snap in
//                if snap.exists(), let snapJSON = snap.value as? JSONObject {
//                    completion(Result.success(snapJSON), eventType)
//                } else {
//                    completion(Result.failure(FirebaseError.incorrectlyFormedData), eventType)
//                }
//            })
//        }
//    }
    
    func unsubscribe(from ref: DatabaseReference) {
        ref.removeAllObservers()
    }
    
    
}
