//
//  CreateObject.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/1/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct CreateObject<T: Identifiable>: Command {
    
    var object: T
    
    func execute(state: AppState, core: Core<AppState>) {
        networkAccess.addObject(at: object.ref, parameters: object.marshaled() as! JSONObject) { result in
            switch result {
            case .success:
                if let _ = self.object as? Group, core.state.groups.isEmpty {
                    core.fire(command: SubscribeToGroups())
                } else if let _ = self.object as? Student, core.state.allStudents.isEmpty {
                    core.fire(command: SubscribeToStudents())
                }
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
