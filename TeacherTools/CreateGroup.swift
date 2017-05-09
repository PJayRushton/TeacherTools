//
//  CreateGroup.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/5/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct CreateGroup: Command {
    
    var name: String
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let user = state.currentUser else { return }
        let ref = networkAccess.groupsRef(userId: user.id).childByAutoId()
        let newGroup = Group(id: ref.key, name: name)
        networkAccess.addObject(at: ref, parameters: newGroup.marshaled()) { result in
            switch result {
            case .success:
                core.fire(event: Selected<Group>(newGroup))
                
                guard let currentUser = state.currentUser else { return }
                let fakeStudentRef = self.networkAccess.studentsRef(userId: currentUser.id)
                self.networkAccess.updateObject(at: fakeStudentRef, parameters: ["fake": true], completion: { result in
                    if case .success = result, !state.hasSubscribedToStudents {
                        core.fire(command: SubscribeToStudents())
                    }
                })
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
