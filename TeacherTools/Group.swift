//
//  Group.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation
import Firebase
import Marshal

struct Group: Identifiable {
    
    var id: String
    var creationDate: Date
    var displayDensity: Float = 0.6
    var name: String
    var studentIds: [String]
    var teamSize = 2
    
    var ref: DatabaseReference {
        return FirebaseNetworkAccess.sharedInstance.groupsRef(userId: App.core.state.currentUser!.id).child(id)
    }
    
    init(id: String, name: String, creationDate: Date = Date(), displayDensity: Float = 0.6, groupSize: Int = 2, studentIds: [String] = [String](), teamSize: Int = 2) {
        self.id = id
        self.name = name
        self.creationDate = creationDate
        self.displayDensity = displayDensity
        self.studentIds = studentIds
        self.teamSize = teamSize
    }
    
}


// MARK: - Unmarshaling

extension Group: Unmarshaling {
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: Keys.id)
        name = try object.value(for: Keys.name)
        creationDate = try object.value(for: Keys.creationDate)
        displayDensity = try object.value(for: Keys.displayDensity) ?? 0.6
        teamSize = try object.value(for: Keys.teamSize) ?? 2
        let studentsDict: JSONObject? = try? object.value(for: Keys.studentIds)
        if let studentsDict = studentsDict {
            studentIds = Array(studentsDict.keys)
        } else {
            studentIds = [String]()
        }
    }
    
}


// MARK: - Marshaling

extension Group: JSONMarshaling {
    
    func jsonObject() -> JSONObject {
        var json = JSONObject()
        json[Keys.id] = id
        json[Keys.name] = name
        json[Keys.creationDate] = creationDate.iso8601String
        json[Keys.displayDensity] = displayDensity
        json[Keys.studentIds] = studentIds.jsonObject()
        json[Keys.teamSize] = teamSize
        
        return json
    }
    
}
