//
//  DeleteObject.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/31/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct DeleteObject<T: Identifiable>: Command {
    
    var object: T
    
    func execute(state: AppState, core: Core<AppState>) {
        networkAccess.deleteObject(at: object.ref) { result in
            switch result {
            case .success:
                guard let group = self.object as? Group else { return }
                core.fire(command: DeleteAllStudents(group: group))
                core.fire(event: Selected<Group>(nil))
                let newGroups = state.groups.filter { $0.id != group.id }
                core.fire(event: Updated<[Group]>(newGroups))
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
