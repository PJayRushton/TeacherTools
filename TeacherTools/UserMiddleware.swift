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
 
class EntityDatabase {
    static let shared = EntityDatabase()
    
    var users = [User]()
}
 
struct ShowPro: Event { }
 
struct UserMiddleware: Middleware {
    
    func process(event: Event, state: AppState) {
        switch event {
        case let event as Updated<[User]>:
            EntityDatabase.shared.users = event.payload
            if state.currentUser == nil {
                App.core.fire(command: GetICloudUser())
            } else if let currentUser = state.currentUser, let index = event.payload.index(of: currentUser) {
                App.core.fire(event: Selected<User>(event.payload[index]))
            }
        case let event as ICloudUserIdentified:
            guard EntityDatabase.shared.users.isEmpty == false else {
                App.core.fire(command: SubscribeToUsers())
                return
            }
            let identifiedUsersByCK = EntityDatabase.shared.users.filter { $0.cloudKitId == event.icloudId }
            let identifiedUsersByDevice = EntityDatabase.shared.users.filter { $0.deviceId == UIDevice.current.identifierForVendor?.uuidString }
            
            if identifiedUsersByCK.count == 1 && event.icloudId != nil, let ckUser = identifiedUsersByCK.first { // IDEAL
                App.core.fire(event: Selected<User>(ckUser))
                print("USER IDENTIFIED BY iCLOUD ID \(ckUser.cloudKitId), \nfirebaseID: \(ckUser.id)")
            } else if identifiedUsersByDevice.count == 1, let deviceUser = identifiedUsersByDevice.first { // No iCloud - Use device id
                App.core.fire(event: Selected<User>(deviceUser))
                print("USER IDENTIFIED BY DEVICE ID \(deviceUser.deviceId)")
                
                if let icloudID = event.icloudId {
                    let updatedUser = deviceUser
                    updatedUser.cloudKitId = icloudID
                    App.core.fire(command: UpdateUser(user: updatedUser))
                }
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
            guard let _ = event.item, isSubscribed == false else { return }
            isSubscribed = true
            App.core.fire(command: SubscribeToGroups())
            App.core.fire(command: SubscribeToStudents())
            App.core.fire(command: GetIAPs())
        case let event as Updated<[Group]>:
            guard state.selectedGroup == nil else { break }
            let sortedGroups = event.payload.sorted { $0.name < $1.name }
            App.core.fire(event: Selected<Group>(sortedGroups.first))
        default:
            break
        }
    }
    
}
