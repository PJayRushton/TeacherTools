//
//  Group.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct Group: Unmarshaling, Marshaling, Identifiable {
    
    var id: String
    var name: String
    var creationDate: Date
    var lastViewDate: Date
    var studentIds: [Student]
    
    var students: [Student] {
        return App.core.state.allStudents.filter { $0.groupIds.contains(id) }
    }
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        name = try object.value(for: "name")
        creationDate = try object.value(for: "creationDate")
        lastViewDate = try object.value(for: "lastViewDate")
        let studentsDict: JSONObject = try object.value(for: "studentIds")
        studentIds = Array(studentsDict.key)
    }
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        json["name"] = name
        json["creationDate"] = creationDate.iso8601String
        json["lastViewDate"] = lastViewDate.iso8601String
        json["studentIds"] = student.marshaled()
        
        return json
    }
    
}
