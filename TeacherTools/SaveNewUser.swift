//
//  SaveNewUser.swift
//  Wasatch Transportation
//
//  Created by Parker Rushton on 10/19/16.
//  Copyright © 2016 PJR. All rights reserved.
//

import Foundation
import Firebase

struct SaveNewUser: Command {
    
    var iCloudId: String
    
    func execute(state: AppState, core: Core<AppState>) {
        let ref = networkAccess.usersRef.childByAutoId()
        let user = User(id: ref.key, cloudKitId: iCloudId, firstName: "First Name")
        
        networkAccess.setValue(at: ref, parameters: user.marshaled()) { result in
            switch result {
            case .success:
                core.fire(command: SubscribeToCurrentUser(id: user.id))
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
