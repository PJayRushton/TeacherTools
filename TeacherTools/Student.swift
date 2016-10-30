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
    var groupIds: [String]
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        firstName = try object.value(for: "firstName")
        lastName = try object.value(for: "lastName")
        let groupsObject: JSONObject = try object.value(for: "groupIds")
        groupIds = Array(groupsObject.keys)
    }
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        json["firstName"] = firstName
        json["lastName"] = lastName
        json["groupIds"] = groupIds.marshaled()
        
        return json
    }
    
}
