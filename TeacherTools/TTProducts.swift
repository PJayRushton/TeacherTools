//
//  TTProducts.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation
import Firebase

struct TTProducts {
    
    static let proUpgrade = "com.PJayRushton.TeacherTools.ProUpgrade"
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [TTProducts.proUpgrade]
    static let store = IAPHelper(productIds: TTProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

struct TTPurchase: JSONMarshaling {
    
    var id: String
    var productId: ProductIdentifier
    var purchaseDate: Date
    
}


// MARK: - Unmarshaling

extension TTPurchase: Unmarshaling {
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: Keys.id)
        productId = try object.value(for: Keys.productId)
        purchaseDate = try object.value(for: Keys.date)
    }
    
}


// MARK: - Marshaling

extension TTPurchase {
    
    func jsonObject() -> JSONObject {
        var object = JSONObject()
        object[Keys.id] = id
        object[Keys.productId] = productId
        object[Keys.date] = purchaseDate.iso8601String
        
        return object
    }
    
}


// MARK: - Equatable

extension TTPurchase: Equatable { }

func ==(lhs: TTPurchase, rhs: TTPurchase) -> Bool {
    return lhs.productId == rhs.productId
}


// MARK: - Hashable

extension TTPurchase: Hashable {
    
    var hashValue: Int {
        return productId.hashValue
    }

}


// MARK: - Identifiable {

extension TTPurchase: Identifiable {
    
    var ref: FIRDatabaseReference {
        let userId = App.core.state.currentUser?.id
        return FirebaseNetworkAccess.sharedInstance.usersRef.child(userId!).child("purchases").child(id)
    }
    
}
