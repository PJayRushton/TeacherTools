//
//  Student.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct Student: Marshaling, Unmarshaling, Identifiable {
    
    var id: String
    var firstName: String
    var lastName: String?
    var tickets = 1
    
    init(id: String, firstName: String, lastName: String? = nil, tickets: Int = 1) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.tickets = tickets
    }
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        firstName = try object.value(for: "firstName")
        lastName = try object.value(for: "lastName")
        tickets = try object.value(for: "tickets")
    }
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        json["firstName"] = firstName
        json["lastName"] = lastName
        json["tickets"] = tickets
        
        return json
    }
    
}
