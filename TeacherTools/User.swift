//
//  User.swift
//  TeacherTools
//
//  Created by Parker Rushton on 1/3/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import Firebase

final class User: Marshaling, Unmarshaling {
    
    var id: String
    var cloudKitId: String?
    var deviceId:  String
    var creationDate: Date
    var firstName: String?
    
    init(id: String = "", cloudKitId: String? = nil, deviceId: String = "", creationDate: Date = Date(), firstName: String? = nil) {
        self.id = id
        self.cloudKitId = cloudKitId
        self.deviceId = deviceId
        self.creationDate = creationDate
        self.firstName = firstName
    }
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        cloudKitId = try object.value(for: "iCloudId")
        deviceId = try object.value(for: "deviceId")
        creationDate = try object.value(for: "creationDate")
        firstName = try object.value(for: "firstName")
    }
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        json["iCloudId"] = cloudKitId
        json["deviceId"] = deviceId
        json["creationDate"] = creationDate.iso8601String
        json["firstName"] = firstName
        
        return json
    }
    
}


// MARK: - Equatable

extension User: Identifiable {
    
    var ref: FIRDatabaseReference {
        return FirebaseNetworkAccess.sharedInstance.usersRef.child(id)
    }
    
}

extension User: Equatable { }

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}
