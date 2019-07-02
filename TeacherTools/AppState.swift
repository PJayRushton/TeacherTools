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
    static let core = Core(state: AppState(), middlewares: [ErrorHUDMiddleware(), AppearanceMiddleware()])
}


// MARK: - State

struct AppState: State {
    
    var currentICloudId: String?
    var currentUser: User?
    var isSubscribedToCurrentUser = false
    var groups = [Group]()
    var groupsAreLoaded = false
    var absentStudents = [Student]()
    var allStudents = [Student]()
    var hasSubscribedToStudents = false
    var theme = defaultTheme
    var allThemes = [Theme]()
    var iaps = [SKProduct]()
    var selectedGroupId: String? {
        get {
            dump(UserDefaults.standard.selectedGroupId)
            return UserDefaults.standard.selectedGroupId
        } set {
            UserDefaults.standard.selectedGroupId = newValue
        }
    }
    
    var currentStudents: [Student] {
        guard let group = selectedGroup else { return [] }
        return currentStudents(of: group, absents: absentStudents)
    }
    var selectedGroup: Group? {
        return groups.first(where: { $0.id == selectedGroupId })
    }
    var isUsingTickets: Bool {
        return currentStudents.first(where: { $0.tickets != 1 }) != nil
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
            theme = allThemes.first { $0.id == event.item?.themeID } ?? defaultTheme
        case _ as Subscribed<User>:
            isSubscribedToCurrentUser = true
            
            // GROUPS
        case let event as Updated<[Group]>:
            let allGroups = event.payload
            groups = allGroups
            groupsAreLoaded = true
            let allIds = allGroups.map { $0.id }
            
            if let selectedId = selectedGroupId {
                if !allIds.contains(selectedId) {
                    selectedGroupId = nil
                }
            } else {
                selectedGroupId = allIds.first
            }
            
        case let event as Selected<Group>:
            selectedGroupId = event.item?.id
            
            if selectedGroup != event.item {
                absentStudents.removeAll()
            }
            // STUDENTS
        case let event as Updated<[Student]>:
            allStudents = event.payload
            hasSubscribedToStudents = true
            
        case let event as MarkStudentAbsent:
            guard let _ = currentStudents.index(of: event.student) else { return }
            absentStudents.append(event.student)
            
        case let event as MarkStudentPresent:
            guard let index = absentStudents.index(of: event.student) else { return }
            absentStudents.remove(at: index)
            
        case let event as Updated<[SKProduct]>:
            iaps = event.payload
            
            // APPEARANCE
        case let event as Updated<[Theme]>:
            allThemes = event.payload
            guard let user = currentUser, let updatedTheme = event.payload.first(where: { $0.id == user.themeID }) else { break }
            theme = updatedTheme
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

struct MarkStudentAbsent: Event {
    var student: Student
}

struct MarkStudentPresent: Event {
    var student: Student
}

struct UploadStatusUpdated: Event {
    var success: Bool?
}

struct SubscriptionStatusUpdated: Event {
    var preAuth: Bool
}

extension UserDefaults {
    
    var selectedGroupId: String? {
        get {
            return string(forKey: #function)
        } set {
            set(newValue, forKey: #function)
            synchronize()
        }
    }
    
}
