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
        
        networkAccess.subscribe(to: ref) { result in
            let userResult = result.map(User.init)
            switch userResult {
            case let .success(user):
                core.fire(event: Selected<User>(user))
                core.fire(event: Subscribed<User>(user))
            case let .failure(error):
                core.fire(event: Selected<User>(nil))
                core.fire(event: Subscribed<User>(nil))
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
