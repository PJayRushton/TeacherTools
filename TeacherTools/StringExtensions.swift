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
        if self.contains(",") {
            let noSpaces = self.replacingOccurrences(of: " ", with: "")
            let parts = noSpaces.components(separatedBy: ",")
            guard let firstName = parts.last, let lastName = parts.first else { return (first: self, last: nil) }
            return (first: firstName, last: lastName)
        } else if self.contains(" ") {
            let parts = self.components(separatedBy: " ")
            guard let firstName = parts.first, let lastName = parts.last else { return (first: self, last: nil) }
            return (first: firstName, last: lastName)
        } else {
            return (first: self, last: nil)
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
        let names = self.components(separatedBy: "\n")
        return names.flatMap { $0.parsed() }
    }
    
}
