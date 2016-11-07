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

var fakeStudent1 = Student(id: "EIHf83nf", firstName: "MacKenzie", lastName: "Williams")
var fakeStudent2 = Student(id: "apsoin3k", firstName: "Amanda", lastName: "Castillo")
var fakeStudent3 = Student(id: "ih3qgreav", firstName: "Holly", lastName: "Rushton")
var fakeStudent4 = Student(id: "9ui3qgirje", firstName: "David", lastName: "Mathews")
var fakeStudent5 = Student(id: "9ui3qg8h67", firstName: "Korina", lastName: "Iyan")
var fakeStudent6 = Student(id: "3q454heddr", firstName: "Josh", lastName: "Palacios")
var fakeStudent7 = Student(id: "bg4asdfrw2", firstName: "Helaman", lastName: "Santo")
var fakeStudent8 = Student(id: "p98iuqhrg4", firstName: "DonCarlos", lastName: "Guiterrez")
var fakeStudent9 = Student(id: "p89ppu43gs", firstName: "Michael", lastName: "Gonzalez")
var fakeStudent10 = Student(id: "09hugrhjof", firstName: "Janina", lastName: "Moran")
var fakeStudent11 = Student(id: "iowtrjtree", firstName: "Albert", lastName: "De la Vega")
var fakeStudent12 = Student(id: "poijq342as", firstName: "Elijah", lastName: "Rushton")
var fakeStudent13 = Student(id: "0oijgqrawe", firstName: "Chloe", lastName: "Castillo")

var allStudents: [Student] {
    return [fakeStudent1, fakeStudent2, fakeStudent3, fakeStudent4, fakeStudent5, fakeStudent6, fakeStudent7, fakeStudent8, fakeStudent9, fakeStudent10, fakeStudent11, fakeStudent12, fakeStudent13]
}

var evenStudents: [Student] {
    return allStudents.filter { allStudents.index(of: $0)! % 2 == 0 }
}

struct LoadFakeUser: Command {

    func execute(state: AppState, core: Core<AppState>) {
        core.fire(event: Selected<User>(fakeUser))
    }
    
}

struct LoadFakeGroups: Command {

    let group1 = Group(id: group1Id, name: "SCIENCE!", studentIds: evenStudents.map { $0.id })
    let group2 = Group(id: group2Id, name: "Labs", studentIds: allStudents.map { $0.id })

    func execute(state: AppState, core: Core<AppState>) {
        core.fire(event: Updated<[Group]>([group1, group2]))
    }
    
}

struct LoadFakeStudents: Command {

    func execute(state: AppState, core: Core<AppState>) {
        core.fire(event: Updated<[Student]>(allStudents))
    }

}
