//
//  UpdateUser.swift
//  Wasatch Transportation
//
//  Created by Parker Rushton on 10/20/16.
//  Copyright © 2016 PJR. All rights reserved.
//

import Foundation

struct UpdateUser: Command {
    
    var user: User
    
    func execute(state: AppState, core: Core<AppState>) {
        let ref = networkAccess.usersRef.child(user.id)
        networkAccess.updateObject(at: ref, parameters: user.marshaled(), completion: nil)
    }

}
