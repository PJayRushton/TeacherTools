//
//  DeleteAllStudents.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/5/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct DeleteAllStudents: Command {
    
    var group: Group
    
    func execute(state: AppState, core: Core<AppState>) {
        let studentsToDelete = state.allStudents.filter { group.studentIds.contains($0.id) }
        for student in studentsToDelete {
            networkAccess.deleteObject(at: student.ref, completion: nil)
        }
    }
    
}
