//
//  AddStudentToGroup.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/5/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct AddStudent: Command {
    
    var student: Student
    var group: Group
    
    init(_ student: Student, to group: Group) {
        self.student = student
        self.group = group
    }
    
    func execute(state: AppState, core: Core<AppState>) {
        var updatedGroup = group
        updatedGroup.studentIds.append(student.id)
        networkAccess.updateObject(at: updatedGroup.ref, parameters: updatedGroup.jsonObject()) { result in
            switch result {
            case .success:
                break
//                core.fire(event: DisplaySuccessMessage(message: "\(self.student.firstName) added!"))
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
