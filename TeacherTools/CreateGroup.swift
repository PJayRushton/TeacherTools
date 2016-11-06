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
                if core.state.groups.isEmpty {
                    core.fire(command: SubscribeToGroups())
                } else {
                    core.fire(event: Selected<Group>(self.group))
                }
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
