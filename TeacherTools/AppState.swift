//
//  State.swift
//  Amanda's Recipes
//
//  Created by Ben Norris on 4/8/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import Foundation
import CoreLocation


// MARK: - APP

enum App {
    static let core = Core(state: AppState(), middlewares: [UserMiddleware(), ErrorHUDMiddleware()])
}


// MARK: - State

struct AppState: State {
    
    var currentICloudId: String?
    var currentUser: User?
    var allUsers = [User]()
    var groups = [Group]()
    var selectedGroup: Group?
    var allStudents = [Student]()
    var theme = defaultTheme
    
    mutating func react(to event: Event) {
        switch event {
            // AUTH
        case let event as ICloudUserIdentified:
            currentICloudId = event.icloudId
            
            // USERS
        case let event as Selected<User>:
            currentUser = event.item
            currentICloudId = event.item == nil ? nil : event.item?.cloudKitId
            
            // GROUPS
        case let event as Updated<[Group]>:
            groups = event.payload
        case let event as Selected<Group>:
            selectedGroup = event.item
            
            // STUDENTS
        case let event as Updated<[Student]>:
            allStudents = event.payload
            
            // APPEARANCE
        case let event as Selected<Theme>:
            theme = event.item!
        default:
            break
        }
    }
    
    
}


extension Command {
    
    var networkAccess: FirebaseNetworkAccess {
        return FirebaseNetworkAccess()
    }
}


// MARK: - Events

// GENERIC

struct Selected<T>: Event {
    var item: T?
    
    init(_ item: T?) {
        self.item = item
    }
    
}

struct Updated<T>: Event {
    var payload: T
    
    init(_ payload: T) {
        self.payload = payload
    }
    
}

// AUTH
struct ICloudUserIdentified: Event {
    var icloudId: String?
}

// OTHER

struct UploadStatusUpdated: Event {
    var success: Bool?
}

struct ReachablilityChanged: Event {
    var reachable: Bool
}

struct SubscriptionStatusUpdated: Event {
    var preAuth: Bool
}

