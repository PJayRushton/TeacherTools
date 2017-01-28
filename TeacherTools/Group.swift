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
    var teamSize = 2
    var studentIds: [String]
    
    var ref: FIRDatabaseReference {
        let currentUser = App.core.state.currentUser!
        if id.isEmpty {
            return FirebaseNetworkAccess.sharedInstance.groupsRef(userId: currentUser.id).childByAutoId()
        } else {
            return FirebaseNetworkAccess.sharedInstance.groupsRef(userId: currentUser.id).child(id)
        }
    }
    
    init(id: String = "", name: String, creationDate: Date = Date(), groupSize: Int = 2, studentIds: [String] = [String](), teamSize: Int = 2) {
        self.id = id
        self.name = name
        self.creationDate = creationDate
        self.studentIds = studentIds
        self.teamSize = teamSize
    }
    
}

extension Group: Unmarshaling, Marshaling {
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        name = try object.value(for: "name")
        creationDate = try object.value(for: "creationDate")
        let size: Int? = try? object.value(for: "teamSize")
        teamSize = size ?? 2

        let studentsDict: JSONObject? = try? object.value(for: "studentIds")
        if let studentsDict = studentsDict {
            studentIds = Array(studentsDict.keys)
        } else {
            studentIds = [String]()
        }
    }
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        json["id"] = id
        json["name"] = name
        json["creationDate"] = creationDate.iso8601String
        json["studentIds"] = studentIds.marshaled()
        json["teamSize"] = teamSize
        
        return json
    }
    
}
