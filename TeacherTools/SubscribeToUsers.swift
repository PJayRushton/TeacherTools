//
//  SubscribeToUsers.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct SubscribeToCurrentUser: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let currentUser = state.currentUser else { return }
        let ref = networkAccess.usersRef.child(currentUser.id)
        networkAccess.subscribe(to: ref) { result in
            let userResult = result.map { (json: JSONObject) -> User in
                return try User(object: json)
            }
            switch userResult {
            case let .success(user):
                core.fire(event: Selected<User>(user))
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
