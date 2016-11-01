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
                break
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
