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

struct TTPurchase: Marshaling {
    
    var id: String
    var productId: ProductIdentifier
    var purchaseDate: Date
    
    func marshaled() -> JSONObject {
        var object = JSONObject()
        object["id"] = id
        object["productId"] = productId
        object["date"] = purchaseDate.iso8601String
        
        return object
    }
    
}

extension TTPurchase: Unmarshaling {
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        productId = try object.value(for: "productId")
        purchaseDate = try object.value(for: "date")
    }
    
}

func ==(lhs: TTPurchase, rhs: TTPurchase) -> Bool {
    return lhs.productId == rhs.productId
}


extension TTPurchase: Identifiable, Hashable, Equatable {
    
    var hashValue: Int {
        return productId.hashValue
    }
    
    var ref: FIRDatabaseReference {
        let userId = App.core.state.currentUser?.id
        return FirebaseNetworkAccess.sharedInstance.usersRef.child(userId!).child("purchases").child(id)
    }
    
}