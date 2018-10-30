//
//  SubscribeToThemes.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/10/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation
import Marshal

struct SubscribeToThemes: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        let ref = networkAccess.allThemesRef
        networkAccess.subscribe(to: ref) { result in
            let usersResult = result.map { (json: JSONObject) -> [Theme] in
                return json.parsedObjects()
            }
            switch usersResult {
            case let .success(themes):
                core.fire(event: Updated<[Theme]>(themes))
            case let .failure(error):
                core.fire(event: ErrorEvent(error: error, message: nil))
            }
        }
    }
    
}
