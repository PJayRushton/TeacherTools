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
        guard let id = ref.key else { return }
        let user = User(id: id, cloudKitId: iCloudId, firstName: "First Name")
        
        networkAccess.setValue(at: ref, parameters: user.jsonObject()) { result in
            switch result {
            case .success:
                core.fire(command: SubscribeToCurrentUser(id: user.id))
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
