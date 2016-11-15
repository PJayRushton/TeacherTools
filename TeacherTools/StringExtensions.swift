//
//  StringExtensions.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/14/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

extension String {
    
    func parsed() -> (first: String, last: String?) {
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
    
}
