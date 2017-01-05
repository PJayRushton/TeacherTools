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
    
    func execute(state: AppState, core: Core<AppState>) {
        let ref = networkAccess.usersRef.childByAutoId()
        let user = newUser()
        user.id = ref.key
        var parameters: JSONObject = user.marshaled()
        parameters["creationDate"] = Date().iso8601String
        networkAccess.setValue(at: ref, parameters: parameters) { result in
            switch result {
            case .success:
                if let cloudKitId = user.cloudKitId {
                    core.fire(event: ICloudUserIdentified(icloudId: cloudKitId))
                } else {
                    core.fire(event: Selected<User>(user))
                }
                let id = self.networkAccess.groupsRef(userId: user.id).childByAutoId().key
                let newGroup = Group(id: id, name: "Your First Class!")
                core.fire(command: CreateGroup(group: newGroup))
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
    private func newUser() -> User {
        let cloudKitId = App.core.state.currentICloudId
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let firstName = "First Name"
        return User(cloudKitId: cloudKitId, deviceId: deviceId, firstName: firstName)
    }
    
}
