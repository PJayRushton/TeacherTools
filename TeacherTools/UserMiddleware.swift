 //
//  UserMiddleware.swift
//  Wasatch Transportation
//
//  Created by Parker Rushton on 10/18/16.
//  Copyright © 2016 PJR. All rights reserved.
//

import UIKit
import AirshipKit
 
var hasSavedNewUser = false
 
 struct S3UploadSuccess: Event {
    var object: S3Uploadable
 }
 
struct UserMiddleware: Middleware {
    
    func process(event: Event, state: AppState) {
        switch event {
        case let event as ICloudUserIdentified:
            guard !state.allUsers.isEmpty else {
                App.core.fire(command: SubscribeToUsers())
                return
            }
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
        case let event as S3UploadSuccess:
            let object = event.object
            if let roll = object as? Roll {
                saveUserData(from: roll, state: state)
            } else if let checklist = object as? VehicleChecklist {
                saveUserData(from: checklist, state: state)
            } else if let receipt = object as? Receipt {
                saveUserData(from: receipt, state: state)
            }
        case let event as Updated<[Push]>:
            guard let currentUser = state.currentUser else { break }
            let subscribedPushes = event.payload.filter { currentUser.tags.contains(where: $0.tags.contains) }
            let unreadMessages = subscribedPushes.filter { $0.isReadByCurrentUser == false }
            UAirship.push().setBadgeNumber(unreadMessages.count)
        default:
            break
        }
    }
    
    private func saveUserData(from roll: Roll, state: AppState) {
        guard let currentUser = state.currentUser else { return }
        currentUser.firstName = roll.driverFirst
        currentUser.lastName = roll.driverLast
        currentUser.routeArea = roll.routeArea
        if let routeType = RouteType(rawValue: roll.type as Int) {
            switch routeType {
            case .morning, .afternoon:
                currentUser.routeId = roll.routeNumber
            case .midDay, .postDay:
                currentUser.routeIdMid = roll.routeNumber
            }
        }
        
        if let tag = Tag(key: roll.routeArea.lowercased()) {
            App.core.fire(command: AddTags(tags: [tag]))
            currentUser.tags.append(tag)
        }
        App.core.fire(command: UpdateUser(user: currentUser))
        App.core.fire(command: SaveRoll(roll: roll))
    }
    
    private func saveUserData(from checklist: VehicleChecklist, state: AppState) {
        guard let currentUser = state.currentUser else { return }
        if let firstName = checklist.driverFirst.value {
            currentUser.firstName = firstName
        }
        if let lastName = checklist.driverLast.value {
            currentUser.lastName = lastName
        }
        if let vehicleId = checklist.vehicleNumber.value {
            currentUser.vehicle?.id = vehicleId
        }
        if let year = checklist.year.value {
            currentUser.vehicle?.year = year
        }
        if let make = checklist.make.value {
            currentUser.vehicle?.make = make
        }
        if let model = checklist.model.value {
            currentUser.vehicle?.model = model
        }
        if let mileageString = checklist.odometer.value, let mileage = Int(mileageString) {
            currentUser.vehicle?.mileage = mileage
        }
        if let oilChangeString = checklist.oilChange.value, let oilChange = Int(oilChangeString) {
            currentUser.vehicle?.nextOilChange = oilChange
        }
        App.core.fire(command: UpdateUser(user: currentUser))
        CoreDataHelper.sharedInstance.saveCDLChecklistData(checklist: checklist, data: checklist.pdfData)
//        App.core.fire(command: SaveChecklist(checklist: checklist)) // Something is broken
    }
    
    private func saveUserData(from receipt: Receipt, state: AppState) {
        guard let currentUser = state.currentUser else { return }
        currentUser.firstName = receipt.driverFirst
        currentUser.lastName = receipt.driverLast
        currentUser.gasPin = receipt.pin
        currentUser.vehicle?.id = receipt.vehicleID
        currentUser.vehicle?.mileage = receipt.odometer

        App.core.fire(command: UpdateUser(user: currentUser))
        App.core.fire(command: SaveReceipt(receipt: receipt))
    }

}
