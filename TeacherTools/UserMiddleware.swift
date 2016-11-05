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
 
struct UserMiddleware: Middleware {
    
    func process(event: Event, state: AppState) {
        switch event {
        case let event as Updated<[User]>:
            print("USERS UPDATED (\(event.payload.count))")
            EntityDatabase.shared.users = event.payload
            if state.currentUser == nil {
                App.core.fire(command: GetICloudUser())
            }
        case let event as ICloudUserIdentified:
            print("iCLOUD ID IDENTIFIED: \(event.icloudId)")
            guard EntityDatabase.shared.users.isEmpty == false else {
                App.core.fire(command: SubscribeToUsers())
                return
            }
            let identifiedUsersByCK = EntityDatabase.shared.users.filter { $0.cloudKitId == event.icloudId }
            let identifiedUsersByDevice = EntityDatabase.shared.users.filter { $0.deviceId == UIDevice.current.identifierForVendor?.uuidString }
            if identifiedUsersByCK.count == 1 && event.icloudId != nil {
                App.core.fire(event: Selected<User>(identifiedUsersByCK.first!))
                print("USER IDENTIFIED BY iCLOUD ID \(identifiedUsersByCK.first!.cloudKitId)")
            } else if identifiedUsersByDevice.count == 1 {
                print("USER IDENTIFIED BY DEVICE ID \(identifiedUsersByCK.first!.deviceId)")
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
            guard let _ = event.item, isSubscribed == false else { return }
            isSubscribed = true
            App.core.fire(command: SubscribeToAllTheThings())
        case let event as Updated<[Group]>:
            guard state.selectedGroup == nil else { break }
            let sortedGroups = event.payload.sorted { $0.lastViewDate > $1.lastViewDate }
            App.core.fire(event: Selected<Group>(sortedGroups.first))
        case let event as Selected<Group>:
            guard let group = event.item else { return }
            App.core.fire(command: UpdateGroupLastView(group: group))
        default:
            break
        }
    }
    
}
