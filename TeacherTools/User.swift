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
    var themeID: String
    var purchases = Set<TTPurchase>()
    
    var theme: Theme? {
        return App.core.state.allThemes.filter { $0.id == themeID }.first
    }
    var isPro: Bool {
        return purchases.map { $0.productId }.contains(TTProducts.proUpgrade)
    }
    
    init(id: String = "", cloudKitId: String? = nil, deviceId: String = "", creationDate: Date = Date(), firstName: String? = nil, themeID: String = "-KYnZO6lWYBECsy4U3fN", purchases: Set<TTPurchase> = []) {
        self.id = id
        self.cloudKitId = cloudKitId
        self.deviceId = deviceId
        self.creationDate = creationDate
        self.firstName = firstName
        self.themeID = themeID
        self.purchases = purchases
    }
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        cloudKitId = try object.value(for: "iCloudId")
        deviceId = try object.value(for: "deviceId")
        creationDate = try object.value(for: "creationDate")
        firstName = try object.value(for: "firstName")
        themeID = try object.value(for: "theme")
        let purchasesJSON: JSONObject? = try object.value(for: "purchases")
        purchases = Set<TTPurchase>(purchasesJSON.parsedObjects())
    }
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        json["id"] = id
        json["iCloudId"] = cloudKitId
        json["deviceId"] = deviceId
        json["creationDate"] = creationDate.iso8601String
        json["firstName"] = firstName
        json["purchases"] = purchases.marshaled()
        json["theme"] = themeID
        
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
