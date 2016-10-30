//
//  SaveNewUser.swift
//  Wasatch Transportation
//
//  Created by Parker Rushton on 10/19/16.
//  Copyright © 2016 PJR. All rights reserved.
//

import Foundation
//import Firebase

struct SaveNewUser: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        let ref = networkAccess.usersRef.childByAutoId()
        var user = newUser()
        user.id = ref.key
        var parameters: JSONObject = user.marshaled()
        parameters["creationDate"] = Date().iso8601String
        networkAccess.setValue(atRef: ref, parameters: parameters) { result in
            switch result {
            case .ok:
                if let cloudKitId = user.cloudKitId {
                    core.fire(event: ICloudUserIdentified(icloudId: cloudKitId))
                } else {
                    core.fire(event: Selected<User>(user))
                }
            case let .error(error):
                core.fire(event: DisplayErrorMessage(error: error, message: nil))
            }
        }
    }
    
    private func newUser() -> User {
        let cloudKitId = App.core.state.currentICloudId
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let firstName = UserDefaults.standard.string(forKey: firstNameKey)
        let lastName = UserDefaults.standard.string(forKey: lastNameKey)
        let tags = [TargetHelper.currentTag]
        let pin = UserDefaults.standard.string(forKey: pinKey)
        
        let vehicleId = UserDefaults.standard.string(forKey: vehicleIDKey)
        let vehicleYear = UserDefaults.standard.string(forKey: yearKey)
        let vehicleMake = UserDefaults.standard.string(forKey: makeKey)
        let vehicleModel = UserDefaults.standard.string(forKey: modelKey)
        let vehicleMileage = UserDefaults.standard.integer(forKey: currentMileageKey)
        let vehicleOC = UserDefaults.standard.integer(forKey: oilChangeKey)
        let vehicle = Vehicle(id: vehicleId, year: vehicleYear, make: vehicleMake, model: vehicleModel, mileage: vehicleMileage, nextOilChange: vehicleOC)
        
        let routeArea = UserDefaults.standard.string(forKey: routeAreaKey)
        let routeId = UserDefaults.standard.string(forKey: routeIDMornKey)
        let routeIdMid = UserDefaults.standard.string(forKey: routeIDMidKey)
        
        return User(cloudKitId: cloudKitId, deviceId: deviceId, firstName: firstName, lastName: lastName, tags: tags, gasPin: pin, vehicle: vehicle, routeArea: routeArea, routeId: routeId, routeIdMid: routeIdMid)
    }
    
}
