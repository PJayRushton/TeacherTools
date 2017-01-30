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
    var absentStudents = [Student]()
    var allStudents = [Student]()
    var hasSubscribedToStudents = false
    var theme = defaultTheme
    var allThemes = [Theme]()
    var iaps = [SKProduct]()
    
    var isUsingTickets: Bool {
        for student in currentStudents {
            if student.tickets != 1 {
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
            theme = allThemes.filter { $0.id == event.item?.themeID }.first ?? defaultTheme
            
            // GROUPS
        case let event as Updated<[Group]>:
            let allGroups = event.payload
            groups = allGroups
            groupsAreLoaded = true
            guard let group = selectedGroup, let index = allGroups.index(of: group) else { break }
            let updatedSelectedGroup = allGroups[index]
            selectedGroup = updatedSelectedGroup
            currentStudents = currentStudents(of: updatedSelectedGroup, absents: absentStudents)
        case let event as Selected<Group>:
            selectedGroup = event.item
            
            if selectedGroup != event.item {
                absentStudents.removeAll()
            }
            if let group = event.item {
                currentStudents = currentStudents(of: group, absents: absentStudents)
            } else {
                currentStudents = [Student]()
            }
            
            // STUDENTS
        case let event as Updated<[Student]>:
            allStudents = event.payload
            guard let group = selectedGroup else { break }
            currentStudents = currentStudents(of: group, absents: absentStudents)
            
            if !hasSubscribedToStudents {
                hasSubscribedToStudents = true
                App.core.fire(command: SubscribeToStudents())
            }
        case let event as SortStudents:
            currentStudents.sort(by: event.sort)
        case let event as MarkStudentAbsent:
            guard let _ = currentStudents.index(of: event.student) else { return }
            absentStudents.append(event.student)
            
            guard let group = selectedGroup else { return }
            currentStudents = currentStudents(of: group, absents: absentStudents)
        case let event as MarkStudentPresent:
            guard let index = absentStudents.index(of: event.student) else { return }
            absentStudents.remove(at: index)
            
            guard let group = selectedGroup else { return }
            currentStudents = currentStudents(of: group, absents: absentStudents)
        case _ as ShuffleTeams:
            currentStudents = currentStudents.shuffled()
            
        case let event as Updated<[SKProduct]>:
            iaps = event.payload
            
            // APPEARANCE
        case let event as Updated<[Theme]>:
            allThemes = event.payload
            guard let user = currentUser else { return }
            let updatedTheme = event.payload.filter { $0.id == user.themeID }.first
            if let newTheme = updatedTheme {
                theme = newTheme
            }
        default:
            break
        }
    }
    
    func currentStudents(of group: Group, absents: [Student]) -> [Student] {
        var currentStudents = allStudents.filter { group.studentIds.contains($0.id) }
        currentStudents = currentStudents.filter { !absents.contains($0) }
        return currentStudents.sorted { $0.displayedName < $1.displayedName }
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

struct MarkStudentAbsent: Event {
    var student: Student
}

struct MarkStudentPresent: Event {
    var student: Student
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

