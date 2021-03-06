//
//  SubscribeToGroups.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation
import Marshal

struct SubscribeToGroups: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let currentUser = state.currentUser else { return }
        let ref = networkAccess.groupsRef(userId: currentUser.id)
        
        
        networkAccess.subscribe(to: ref) { result in
            let groupsResult = result.map { (json: JSONObject) -> [Group] in
                return json.parsedObjects()
            }
            switch groupsResult {
            case let .success(groups):
                core.fire(event: Updated<[Group]>(groups))
            case let .failure(error):
                core.fire(event: Updated<[Group]>([Group]()))
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
