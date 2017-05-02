//
//  SubscribeToReachability.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/5/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct ReachablilityChanged: Event {
    var reachable: Bool
}

struct SubscribeToReachability: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        networkAccess.subscribeToReachability { isReachable in
            guard let isReachable = isReachable else { return }
            core.fire(event: ReachablilityChanged(reachable: isReachable))
        }
    }
    
}
