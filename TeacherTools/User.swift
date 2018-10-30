//
//  User.swift
//  TeacherTools
//
//  Created by Parker Rushton on 1/3/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import Firebase

final class User: Unmarshaling {
    
    var id: String
    var cloudKitId: String?
    var creationDate: Date
    var firstName: String?
    var themeID: String
    var lastFirst: Bool
    var purchases = Set<TTPurchase>()
    
    var theme: Theme? {
        return App.core.state.allThemes.filter { $0.id == themeID }.first
    }
    var isPro: Bool {
        return purchases.map { $0.productId }.contains(TTProducts.proUpgrade) || UserDefaults.standard.userIsPro
    }
    
    init(id: String = UUID().uuidString, cloudKitId: String? = nil, creationDate: Date = Date(), firstName: String? = nil, themeID: String = "-KYnZO6lWYBECsy4U3fN", lastFirst: Bool = false, purchases: Set<TTPurchase> = []) {
        self.id = id
        self.cloudKitId = cloudKitId
        self.creationDate = creationDate
        self.firstName = firstName
        self.themeID = themeID
        self.lastFirst = lastFirst
        self.purchases = purchases
    }
    
    // MARK: - Unmarshaling
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: Keys.id)
        cloudKitId = try object.value(for: Keys.iCloudIdKey)
        creationDate = try object.value(for: Keys.creationDate)
        firstName = try object.value(for: Keys.firstName)
        themeID = try object.value(for: Keys.theme)
        lastFirst = try object.value(for: Keys.lastFirst)
        let purchasesJSON: JSONObject? = try object.value(for: Keys.purchases)
        purchases = Set<TTPurchase>(purchasesJSON.parsedObjects())
    }
    
}


//  MARK - Marshaling

extension User: JSONMarshaling {
    
    func jsonObject() -> JSONObject {
        var json = JSONObject()
        json[Keys.id] = id
        json[Keys.iCloudIdKey] = cloudKitId
        json[Keys.creationDate] = creationDate.iso8601String
        json[Keys.firstName] = firstName
        json[Keys.purchases] = purchases.jsonObject()
        json[Keys.lastFirst] = lastFirst
        json[Keys.theme] = themeID
        
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
