//
//  UpdateGroupLastView.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/5/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct UpdateGroupLastView: Command {
    
    var group: Group
    
    func execute(state: AppState, core: Core<AppState>) {
        var updatedGroup = group
        updatedGroup.lastViewDate = Date()
        networkAccess.updateObject(at: updatedGroup.ref, parameters: updatedGroup.marshaled(), completion: nil)
    }
    
}
