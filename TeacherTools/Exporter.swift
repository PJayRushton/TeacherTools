//
//  Exporter.swift
//  TeacherTools
//
//  Created by Parker Rushton on 1/27/17.
//  Copyright © 2017 AppsByPJ. All rights reserved.
//

import Foundation

struct Exporter {
    
    static func exportStudentList(state: AppState) -> String {
        let students = state.currentStudents
        let names = students.map { $0.displayedName }
        return names.joined(separator: "\n")
    }
    
}
