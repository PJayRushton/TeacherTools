//
//  SubscribeToCurrentUser.swift
//  Stats
//
//  Created by Parker Rushton on 3/31/17.
//  Copyright © 2017 AppsByPJ. All rights reserved.
//

import Foundation

struct Subscribed<T: Identifiable>: Event {
    
    var item: T?
    
    init(_ item: T?) {
        self.item = item
    }
    
}

struct SubscribeToCurrentUser: Command {
    
    var id: String
    
    func execute(state: AppState, core: Core<AppState>) {
        let ref = networkAccess.usersRef.child(id)
        networkAccess.unsubscribe(from: ref)
        
        let dispatchGroup = DispatchGroup()
        
        let groupsRef = networkAccess.groupsRef(userId: id)
        let studentsRef = networkAccess.studentsRef(userId: id)
        let refs = [groupsRef, studentsRef]
        
        for ref in refs {
            dispatchGroup.enter()
            networkAccess.updateObject(at: ref, parameters: ["fake": true], completion: { result in
                if case let .failure(error) = result {
                    core.fire(event: ErrorEvent(error: error, message: nil))
                }
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            core.fire(command: SubscribeToGroups())
            core.fire(command: SubscribeToStudents())
            
            self.networkAccess.subscribe(to: ref, completion: { result in
                let userResult = result.map(User.init)
                switch userResult {
                case let .success(user):
                    core.fire(event: Selected<User>(user))
                    core.fire(event: Subscribed<User>(user))
                case let .failure(error):
                    core.fire(event: Selected<User>(nil))
                    core.fire(event: ErrorEvent(error: error, message: nil))
                }
            })
        }
    }
    
}
