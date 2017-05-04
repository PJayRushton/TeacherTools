//
//  CreateGroup.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/5/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct CreateGroup: Command {
    
    var group: Group
    
    func execute(state: AppState, core: Core<AppState>) {
        networkAccess.addObject(at: group.ref, parameters: group.marshaled()) { result in
            switch result {
            case .success:
                core.fire(event: Selected<Group>(self.group))
                
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
