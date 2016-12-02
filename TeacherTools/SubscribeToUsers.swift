//
//  SubscribeToUsers.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct SubscribeToUsers: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        let ref = networkAccess.usersRef
        networkAccess.subscribe(to: ref) { result in
            let usersResult = result.map { (json: JSONObject) -> [User] in
                return json.parsedObjects()
            }
            switch usersResult {
            case let .success(users):
                core.fire(event: Updated<[User]>(users))
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
