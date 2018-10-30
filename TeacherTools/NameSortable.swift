//
//  NameSortable.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/18.
//  Copyright © 2018 AppsByPJ. All rights reserved.
//

import Foundation

protocol NameSortable {
    var firstName: String { get set }
    var lastName: String? { get set }
}


// MARK: - Sorting functions

extension Array where Element == NameSortable {
    
    func sortedByFirstName(ascending: Bool = true) -> [Element] {
        return self.sorted { return ascending ? $0.firstName < $1.firstName : $0.firstName > $1.firstName }
    }
    
    func sortedByLastName(ascending: Bool = true) -> [Element] {
        return self.sorted { first, second in
            let firstName = first.lastName ?? first.firstName
            let secondName = second.lastName ?? second.firstName
            return ascending ? firstName < secondName : firstName > secondName
        }
    }
    
}
