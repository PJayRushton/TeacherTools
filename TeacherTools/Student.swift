//
//  Student.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation
import Firebase

struct Student: Identifiable, NameSortable {
    
    var id: String
    var firstName: String
    var lastName: String?
    var tickets = 1
    var name: FullName {
        get {
            return (firstName, lastName)
        }
        set {
            firstName = name.first
            lastName = name.last
        }
    }
    
    var displayedName: String {
        guard let lastName = lastName, let currentUser = App.core.state.currentUser else { return firstName }
        return currentUser.lastFirst ? "\(lastName), \(firstName)" : "\(firstName) \(lastName)"
    }
    
    var ref: FIRDatabaseReference {
        return FirebaseNetworkAccess.sharedInstance.studentsRef(userId: App.core.state.currentUser!.id).child(id)
    }
    
    init(id: String, fullName: FullName) {
        self.id = id
        self.firstName = fullName.first
        self.lastName = fullName.last
        self.tickets = 1
    }
    
    init(id: String, name: String, tickets: Int = 1) {
        self.id = id
        let parsedName = name.parsed()
        self.firstName = parsedName.first
        self.lastName = parsedName.last
        self.tickets = tickets
    }
    
}


// MARK: - Marshaling

extension Student: Unmarshaling {
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: Keys.id)
        firstName = try object.value(for: Keys.firstName)
        lastName = try object.value(for: Keys.lastName)
        tickets = try object.value(for: Keys.tickets)
    }
    
}


// MARK: - Marshaling

extension Student: JSONMarshaling {
    
    func jsonObject() -> JSONObject {
        var json = JSONObject()
        json[Keys.id] = id
        json[Keys.firstName] = firstName
        json[Keys.lastName] = lastName
        json[Keys.tickets] = tickets
        
        return json
    }
    
}
