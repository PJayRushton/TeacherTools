//
//  SaveStudentList.swift
//  TeacherTools
//
//  Created by Parker Rushton on 1/3/17.
//  Copyright © 2017 AppsByPJ. All rights reserved.
//

import Foundation

struct SaveStudentList: Command {
    
    var names: [FullName]
    var replace: Bool
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let currentUser = state.currentUser, let currentGroup = state.selectedGroup else { return }
        let students = names.flatMap { Student(id: networkAccess.studentsRef(userId: currentUser.id).childByAutoId().key, fullName: $0) }
        
        for (index, student) in students.enumerated() {
            networkAccess.addObject(at: student.ref, parameters: student.marshaled()) { _ in
                if index == students.count - 1 {
                    self.updateGroupStudents(students, currentGroup: currentGroup, user: currentUser)
                }
            }
        }
    }
    
    func updateGroupStudents(_ students: [Student], currentGroup: Group, user: User) {
        let newStudentIds = students.map { $0.id }
        if replace {
            let idsToDelete = currentGroup.studentIds.filter { !newStudentIds.contains($0) }
            if !idsToDelete.isEmpty {
                idsToDelete.forEach({ id in
                    let refToNuke = self.networkAccess.studentsRef(userId: user.id).child(id)
                    self.networkAccess.deleteObject(at: refToNuke, completion: nil)
                })
            }
            var updatedGroup = currentGroup
            updatedGroup.studentIds = newStudentIds
            networkAccess.updateObject(at: updatedGroup.ref, parameters: updatedGroup.marshaled(), completion: nil)
        } else {
            var updatedGroup = currentGroup
            updatedGroup.studentIds.append(contentsOf: newStudentIds)
            networkAccess.updateObject(at: updatedGroup.ref, parameters: updatedGroup.marshaled(), completion: nil)
        }
    }
    
}
