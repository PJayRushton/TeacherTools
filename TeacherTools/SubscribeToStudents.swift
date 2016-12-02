//
//  SubscribeToStudents.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct SubscribeToStudents: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let currentUser = state.currentUser else { return }
        let ref = networkAccess.studentsRef(userId: currentUser.id)
        networkAccess.subscribe(to: ref) { result in
            let studentsResult = result.map { (json: JSONObject) -> [Student] in
                return json.parsedObjects()
            }
            
            switch studentsResult {
            case let .success(students):
                core.fire(event: Updated<[Student]>(students))
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
