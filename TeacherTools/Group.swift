//
//  Group.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation
import Firebase

struct Group: Identifiable {
    
    var id: String
    var name: String
    var creationDate: Date
    var lastViewDate: Date
    var studentIds: [String]
    
    var students: [Student] {
        return App.core.state.allStudents.filter { studentIds.contains($0.id) }
    }
    
    var ref: FIRDatabaseReference {
        return FirebaseNetworkAccess.sharedInstance.groupsRef(userId: App.core.state.currentUser!.id).child(id)
    }
    
    init(id: String, name: String, creationDate: Date = Date(), lastViewDate: Date = Date(), studentIds: [String]) {
        self.id = id
        self.name = name
        self.creationDate = creationDate
        self.lastViewDate = lastViewDate
        self.studentIds = studentIds
    }
    
}

extension Group: Unmarshaling {
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        name = try object.value(for: "name")
        creationDate = try object.value(for: "creationDate")
        lastViewDate = try object.value(for: "lastViewDate")
        let studentsDict: JSONObject = try object.value(for: "studentIds")
        studentIds = Array(studentsDict.keys)
    }
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        json["name"] = name
        json["creationDate"] = creationDate.iso8601String
        json["lastViewDate"] = lastViewDate.iso8601String
        json["studentIds"] = students.marshaled()
        
        return json
    }
    
}
