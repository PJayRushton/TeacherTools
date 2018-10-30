//
//  Command.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/6/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct UpdateTeamSize: Command {
    
    var size: Int
    
    func execute(state: AppState, core: Core<AppState>) {
        guard var updatedGroup = state.selectedGroup else { core.fire(event: NoOp()); return }
        updatedGroup.teamSize = size
        networkAccess.updateObject(at: updatedGroup.ref, parameters: updatedGroup.jsonObject()) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
