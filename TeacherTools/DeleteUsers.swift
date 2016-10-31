//
//  DeleteUsers.swift
//  Wasatch Transportation
//
//  Created by Parker Rushton on 10/19/16.
//  Copyright © 2016 PJR. All rights reserved.
//

import Foundation

struct DeleteUsers: Command {
    
    var users: [User]
    
    func execute(state: AppState, core: Core<AppState>) {
        guard users.count > 1 else { return }
        var sortedUsers = users.sorted { $0.creationDate < $1.creationDate }
        sortedUsers.removeLast()
        for (index, user) in sortedUsers.enumerated() {
            let ref = networkAccess.usersRef.child(user.id)
            networkAccess.deleteObject(at: ref) { result in
                if index == self.users.count - 1 {
                    core.fire(command: GetICloudUser())
                }
            }
        }
    }
    
}
