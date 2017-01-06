//
//  StringExtensions.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/14/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

typealias FullName = (first: String, last: String?)

extension String {
    
    func parsed() -> FullName {
        var nameString = self
        if let lastChar = nameString.characters.last, lastChar == "," {
            nameString.characters.removeLast()
        }
        if nameString.contains(",") {
            let noSpaces = nameString.replacingOccurrences(of: " ", with: "")
            let parts = noSpaces.components(separatedBy: ",")
            guard let firstName = parts.last, let lastName = parts.first else { return (first: nameString, last: nil) }
            return (first: firstName, last: lastName)
        } else if nameString.contains(" ") {
            let parts = nameString.components(separatedBy: " ")
            guard let firstName = parts.first, let lastName = parts.last else { return (first: nameString, last: nil) }
            return (first: firstName, last: lastName)
        } else {
            return (first: nameString, last: nil)
        }
    }
    
    var isValidName: Bool {
        guard self.isEmpty == false else { return false }
        let hasComma = self.contains(",")
        let hasSpace = self.contains(" ")
        if !hasComma && !hasSpace {
            return true
        } else if hasSpace {
            return self.components(separatedBy: " ").count == 2
        }
        return true
    }
    
    func studentList() -> [FullName] {
        let names = self.components(separatedBy: "\n").filter { $0.isEmpty == false }
        return names.flatMap { $0.parsed() }
    }
    
}
