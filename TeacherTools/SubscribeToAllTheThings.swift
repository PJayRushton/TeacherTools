//
//  SubscribeToAllTheThings.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct SubscribeToAllTheThings: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        core.fire(command: SubscribeToThemes())
        core.fire(command: SubscribeToUsers())
        core.fire(command: SubscribeToGroups())
        core.fire(command: SubscribeToStudents())
    }
    
}
