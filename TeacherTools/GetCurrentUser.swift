//
//  GetCurrentUser.swift
//  Stats
//
//  Created by Parker Rushton on 3/28/17.
//  Copyright © 2017 AppsByPJ. All rights reserved.
//

import Foundation

struct GetCurrentUser: Command {
    
    var iCloudId: String
    
    func execute(state: AppState, core: Core<AppState>) {
        let query = networkAccess.usersRef.queryOrdered(byChild: iCloudId).queryEqual(toValue: iCloudId)
        networkAccess.getData(withQuery: query) { result in
            let userResult = result.map { (json: JSONObject) -> User in
                guard let key = json.keys.first else { throw MarshalError.nullValue(key: "User Search Failed")}
                let userJSON: JSONObject = try json.value(for: key)
                return try User(object: userJSON)
            }
            switch userResult {
            case let .success(user):
                core.fire(event: Selected<User>(user))
                core.fire(command: SubscribeToCurrentUser(id: user.id))
                core.fire(command: GetIAPs())
            case let .failure(error):
                core.fire(event: Selected<User>(nil))
                core.fire(command: SaveNewUser(iCloudId: self.iCloudId))
                core.fire(event: ErrorEvent(error: error, message: "Unable to find user with iCloudId: \(self.iCloudId)"))
            }
        }
    }
    
}
    
