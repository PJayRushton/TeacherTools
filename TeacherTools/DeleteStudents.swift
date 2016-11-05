//
//  DeleteStudents.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/5/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct DeleteStudents: Command {
    
    var group: Group
    
    func execute(state: AppState, core: Core<AppState>) {
        for student in group.students {
            networkAccess.deleteObject(at: student.ref, completion: nil)
        }
    }
    
}
