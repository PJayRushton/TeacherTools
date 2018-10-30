//
//  UpdateTheme.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/10/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct UpdateTheme: Command {
    
    var theme: Theme
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let currentUser = core.state.currentUser else { return }
        currentUser.themeID = theme.id
        let ref = networkAccess.usersRef.child(currentUser.id)
        networkAccess.updateObject(at: ref, parameters: currentUser.jsonObject(), completion: nil)
    }
    
}
