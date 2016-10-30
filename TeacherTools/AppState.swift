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
    static let core = Core(state: AppState(), middlewares: [ReachabilityMiddleware(), ErrorHUDMiddleware(), UserMiddleware()])
}


// MARK: - State

struct AppState: State {
    
    var currentICloudId: String?
    var currentUserId: String?
    var currentUser: User?
    var allUsers = [User]()
    var contacts = [Contact]()
    var selectedContact: Contact?
    var documents = [Document]()
    var insuranceDocs: [Document]?
    var pushes = [Push]()
    var selectedPush: Push?
    var adminState = AdminState()
    var currentLocation: CLLocation?
    var uploadResult: Bool?
    var appLink: URL?
    
    var currentLocationDescription: String {
        return currentLocation?.coordinateString ?? " Not found"
    }
    
    mutating func react(to event: Event) {
        switch event {
            // AUTH
        case let event as UserIdentified:
            currentUserId = event.userId
        case let event as ICloudUserIdentified:
            currentICloudId = event.icloudId
        case _ as UserLoggedOut:
            currentUserId = nil
            
            // USERS
        case let event as Selected<User>:
            currentUser = event.item
        case let event as Updated<[User]>:
            allUsers = event.payload
            
            // CONTACTS
        case let event as Updated<[Contact]>:
            contacts = event.payload.sorted { $0.firstName < $1.firstName }
        case let event as Selected<Contact>:
            selectedContact = event.item
            
            // DOCUMENTS
        case let event as Updated<[Document]>:
            documents = event.payload
        case let event as InsuranceDocsUpdated:
            insuranceDocs = event.docs
            // PUSHES
        case let event as Updated<[Push]>:
            pushes = event.payload
            guard let selectedPush = selectedPush, let index = event.payload.index(of: selectedPush) else { break }
            self.selectedPush = event.payload[index]
        case let event as Selected<Push>:
            selectedPush = event.item
            // LOCATION
        case let event as Selected<CLLocation>:
            currentLocation = event.item
            // UPLOAD RESULT
        case let event as UploadStatusUpdated:
            uploadResult = event.success
            // APP URL
        case let event as Selected<URL>:
            appLink = event.item
        default:
            break
        }
        
        adminState.react(to: event)
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


struct UserIdentified: Event {
    var userId: String?
}

struct UserLoggedOut: Event { }

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

