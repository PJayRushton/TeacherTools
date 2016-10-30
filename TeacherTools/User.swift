//
//  User.swift
//  Amanda's Recipes
//
//  Created by Parker Rushton on 1/3/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

final class User: Marshaling, Unmarshaling {
    
    var id: String
    var cloudKitId: String?
    var deviceId:  String
    var creationDate: Date
    
    init(id: String = "", cloudKitId: String? = nil, deviceId: String = "", creationDate: Date = Date(),company: Company = TargetHelper.currentCompany, firstName: String? = nil, lastName: String? = nil, tags: [Tag] = [Tag](), gasPin: String? = nil, vehicle: Vehicle? = nil, routeArea: String?, routeId: String? = nil, routeIdMid: String? = nil) {
        self.id = id
        self.cloudKitId = cloudKitId
        self.deviceId = deviceId
        self.creationDate = creationDate
        self.company = company
        self.firstName = firstName
        self.lastName = lastName
        self.tags = tags
        self.gasPin = gasPin
        self.vehicle = vehicle
        self.routeArea = routeArea
        self.routeId = routeId
        self.routeIdMid = routeIdMid
    }
    
    init(object: MarshaledObject) throws {
        id = try object <| "id"
        cloudKitId = try object <| "ckId"
        deviceId = try object <| "deviceId"
        creationDate = try object <| "creationDate"
        company = try object <| "company"
        firstName = try object <| "firstName"
        lastName = try object <| "lastName"
        let tagsDict: JSONObject = try object <| "tags"
        tags = Array(tagsDict.keys).flatMap { Tag(key: $0) }
        gasPin = try object <| "gasPin"
        vehicle = try object <| "vehicle"
        routeArea = try object <| "routeArea"
        routeId = try object <| "routeId"
        routeIdMid = try object <| "routeIdMid"
    }
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        json["ckId"] = cloudKitId
        json["deviceId"] = deviceId
        json["company"] = company.rawValue
        json[Keys.firstNameKey] = firstName 
        json[Keys.lastNameKey] = lastName
        json["tags"] = tags.map { $0.key }.marshaled()
        json["gasPin"] = gasPin
        json["vehicle"] = vehicle?.marshaled()
        json["routeArea"] = routeArea
        json["routeId"] = routeId
        json["routeIdMid"] = routeIdMid
        
        return json
    }
    
}


// MARK: - Equatable

extension User: Equatable { }

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}
