//
//  State.swift
//  Amanda's Recipes
//
//  Created by Ben Norris on 4/8/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import Foundation
import CoreLocation
import StoreKit

// MARK: - APP

enum App {
    static let core = Core(state: AppState(), middlewares: [UserMiddleware(), ErrorHUDMiddleware(), AppearanceMiddleware()])
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
    var theme = whiteTheme
    var allThemes = [Theme]()
    var iaps = [SKProduct]()
    
    var isUsingTickets: Bool {
        for student in currentStudents {
            if student.tickets == 0 || student.tickets > 1 {
                return true
            }
        }
        
        return false
    }
    
    mutating func react(to event: Event) {
        switch event {
            // AUTH
        case let event as ICloudUserIdentified:
            currentICloudId = event.icloudId
            
            // USERS
        case let event as Selected<User>:
            currentUser = event.item
            currentICloudId = event.item == nil ? nil : event.item?.cloudKitId
            theme = event.item?.theme ?? whiteTheme
            
            // GROUPS
        case let event as Updated<[Group]>:
            let allGroups = event.payload
            groups = allGroups
            groupsAreLoaded = true
            guard let group = selectedGroup, let index = allGroups.index(of: group) else { break }
            let updatedSelectedGroup = allGroups[index]
            selectedGroup = updatedSelectedGroup
            currentStudents = currentStudents(of: updatedSelectedGroup)
        case let event as Selected<Group>:
            selectedGroup = event.item
            if let group = event.item {
                currentStudents = currentStudents(of: group)
            } else {
                currentStudents = [Student]()
            }
            
            // STUDENTS
        case let event as Updated<[Student]>:
            allStudents = event.payload
            guard let group = selectedGroup else { break }
            currentStudents = currentStudents(of: group)
        case let event as SortStudents:
            currentStudents.sort(by: event.sort)
        case _ as ShuffleTeams:
            currentStudents = currentStudents.shuffled()
            
        case let event as Updated<[SKProduct]>:
            iaps = event.payload
            
            // APPEARANCE
        case let event as Selected<Theme>:
            theme = event.item ?? whiteTheme
        default:
            break
        }
    }
    
    func currentStudents(of group: Group) -> [Student] {
        return allStudents.filter { group.studentIds.contains($0.id) }.sorted { $0.displayedName < $1.displayedName }
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

struct UploadStatusUpdated: Event {
    var success: Bool?
}

struct ReachablilityChanged: Event {
    var reachable: Bool
}

struct SubscriptionStatusUpdated: Event {
    var preAuth: Bool
}

