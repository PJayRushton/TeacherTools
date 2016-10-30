//
//  SubscribeToGroups.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct SubscribeToGroups: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let currentUser = state.currentUser else { return }
        let ref = networkAccess.groupsRef(currentUser.id)
        networkAccess.subscribe(to: ref) { result in
            let groupsResult = result.map { (json: JSONObject) -> [Group] in
                let classIds = Array(json.keys)
                return classIds.map { Group(object: $0) }
            }
            switch groupsResult {
            case let .success(groups):
                core.fire(event: Updated<[Group]>(groups))
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
