//
//  TestHelper.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

let fakeUser = User(id: "-Kud72jKowj03jA3", cloudKitId: "_And;lkfjieb894j9gry", deviceId: "SBACO-LKDJF-OKEJF-78DO8", creationDate: Date(), firstName: "Lord Farquad")

let group1Id = "09oi;q4oraeh"
let group2Id = "jsqar8efd8"

let student1Id = "EIHf83nf"
let student2Id = "apsoin3k"
let student3Id = "ih3qgreav"
let student4Id = "9ui3qgirje"

struct LoadAllTheFakeThings: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
    }

}

struct LoadFakeUser: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        core.fire(event: Selected<User>(fakeUser))
    }
    
}

struct LoadFakeGroups: Command {
    let group1 = Group(id: group1Id, name: "SCIENCE!", studentIds: [student1Id, student3Id])
    let group2 = Group(id: group2Id, name: "Labs", studentIds: [student1Id, student2Id, student4Id])

    func execute(state: AppState, core: Core<AppState>) {
        core.fire(event: Updated<[Group]>([group1, group2]))
    }
    
}

struct LoadFakeStudents: Command {
    
    var fakeStudent1 = Student(id: "EIHf83nf", firstName: "MacKenzie", lastName: "Williams")
    var fakeStudent2 = Student(id: "apsoin3k", firstName: "Amanda", lastName: "Castillo")
    var fakeStudent3 = Student(id: "ih3qgreav", firstName: "Holly", lastName: "Rushton")
    var fakeStudent4 = Student(id: "9ui3qgirje", firstName: "David", lastName: "Mathews")
    
    func execute(state: AppState, core: Core<AppState>) {
        core.fire(event: Updated<[Student]>([fakeStudent1, fakeStudent2, fakeStudent3, fakeStudent4]))
    }

}
