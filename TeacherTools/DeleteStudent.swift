//
//  DeleteStudent.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/5/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct DeleteStudent: Command {
    
    var student: Student
    
    func execute(state: AppState, core: Core<AppState>) {
        networkAccess.deleteObject(at: student.ref, completion: nil)
        guard var editedGroup = state.selectedGroup, let studentIndex = editedGroup.studentIds.index(of: student.id) else { return }
        editedGroup.studentIds.remove(at: studentIndex)
        networkAccess.updateObject(at: editedGroup.ref, parameters: editedGroup.marshaled(), completion: nil)
    }
    
}
