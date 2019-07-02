//
//  Student.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation
import Firebase
import Marshal

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
            firstName = newValue.first
            lastName = newValue.last
        }
    }
    
    var displayedName: String {
        guard let lastName = lastName, let currentUser = App.core.state.currentUser else { return firstName }
        return currentUser.lastFirst ? "\(lastName), \(firstName)" : "\(firstName) \(lastName)"
    }
    
    var ref: DatabaseReference {
        return FirebaseNetworkAccess.sharedInstance.studentsRef(userId: App.core.state.currentUser!.id).child(id)
    }
    
    init(id: String = UUID().uuidString, fullName: FullName) {
        self.id = id
        self.firstName = fullName.first
        self.lastName = fullName.last
        self.tickets = 1
    }
    
    init(id: String = UUID().uuidString, name: String, tickets: Int = 1) {
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


// MARK: - Hashable

extension Student: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}


// MARK: - Sequence Extension

extension Sequence where Element == Student {
    
    func sorted(by type: SortType) -> [Element] {
        switch type {
        case .first:
            return sortedByFirstName()
        case .last:
            return sortedByLastName()
        case .tickets:
            return sortedByTickets()
        }
    }
    
    func sortedByFirstName() -> [Element] {
        return sorted { $0.firstName < $1.firstName }
    }
    
    func sortedByLastName() -> [Element] {
        return sorted { first, second in
            if let firstLastName = first.lastName, let secondLastName = second.lastName {
                return firstLastName < secondLastName
            } else {
                return first.firstName < second.firstName
            }
        }
    }
    
    func sortedByTickets() -> [Element] {
        return sorted(by: { $0.tickets > $1.tickets })
    }
    
}
