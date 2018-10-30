//
//  CreateStudent.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/5/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct CreateStudent: Command {
    
    var student: Student
    
    func execute(state: AppState, core: Core<AppState>) {
        networkAccess.addObject(at: student.ref, parameters: student.jsonObject()) { result in
            switch result {
            case .success:
                if state.allStudents.isEmpty {
                    core.fire(command: SubscribeToStudents())
                }
                if let selectedGroup = state.selectedGroup {
                    core.fire(command: AddStudent(self.student, to: selectedGroup))
                }
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
