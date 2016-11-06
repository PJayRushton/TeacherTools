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
    var groups = [Group]()
    var groupsAreLoaded = false
    var selectedGroup: Group?
    var currentStudents = [Student]()
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
            groupsAreLoaded = true
            guard let group = selectedGroup, let index = event.payload.index(of: group) else { break }
            selectedGroup = event.payload[index]
        case let event as Selected<Group>:
            selectedGroup = event.item
            if let group = event.item {
                currentStudents = allStudents.filter { group.studentIds.contains($0.id) }.sorted { $0.displayedName < $1.displayedName }
            } else {
                currentStudents = [Student]()
            }
            
            // STUDENTS
        case let event as Updated<[Student]>:
            allStudents = event.payload
        case let event as SortStudents:
            currentStudents.sort(by: event.sort)
        case _ as ShuffleTeams:
            currentStudents = currentStudents.shuffled()
            
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

struct ShuffleTeams: Event { }

struct SortStudents: Event {
    var sort: (Student, Student) -> Bool
}

struct NameDisplayChanged: Event {
    var lastFirst: Bool
}

struct UploadStatusUpdated: Event {
    var success: Bool?
}

struct ReachablilityChanged: Event {
    var reachable: Bool
}

struct SubscriptionStatusUpdated: Event {
    var preAuth: Bool
}

