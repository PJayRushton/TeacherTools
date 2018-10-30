//
//  UpdateStudent.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/31/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation
import Marshal

struct UpdateObject<T: Identifiable>: Command {
    
    var object: T
    
    func execute(state: AppState, core: Core<AppState>) {
        networkAccess.updateObject(at: object.ref, parameters: object.jsonObject()) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }

        }
    }
    
}
