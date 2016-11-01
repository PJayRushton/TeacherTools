 //
//  UserMiddleware.swift
//  Wasatch Transportation
//
//  Created by Parker Rushton on 10/18/16.
//  Copyright © 2016 PJR. All rights reserved.
//

import UIKit
 
var hasSavedNewUser = false
var isSubscribed = false
 
struct UserMiddleware: Middleware {
    
    func process(event: Event, state: AppState) {
        switch event {
        case let event as ICloudUserIdentified:
            let identifiedUsersByCK = state.allUsers.filter { $0.cloudKitId == event.icloudId }
            let identifiedUsersByDevice = state.allUsers.filter { $0.deviceId == UIDevice.current.identifierForVendor?.uuidString }
            if identifiedUsersByCK.count == 1 && event.icloudId != nil {
                App.core.fire(event: Selected<User>(identifiedUsersByCK.first!))
            } else if identifiedUsersByDevice.count == 1 {
                App.core.fire(event: Selected<User>(identifiedUsersByDevice.first!))
            } else if identifiedUsersByCK.count > 1 {
                App.core.fire(command: DeleteUsers(users: identifiedUsersByCK))
            } else if identifiedUsersByDevice.count > 1 {
                App.core.fire(command: DeleteUsers(users: identifiedUsersByDevice))
            } else {
                guard hasSavedNewUser == false else { return }
                hasSavedNewUser = true
                App.core.fire(command: SaveNewUser())
            }
        case let event as Selected<User>:
            guard let user = event.item, isSubscribed == false else { return }
            isSubscribed = true
//            App.core.fire(command: SubscribeToAllTheThings())
            
        default:
            break
        }
    }
    
}
