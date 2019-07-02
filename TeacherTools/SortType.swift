//
//  SortType.swift
//  TeacherTools
//
//  Created by Parker Rushton on 6/11/19.
//  Copyright © 2019 AppsByPJ. All rights reserved.
//

import Foundation

enum SortType: Int, CaseIterable {
    case first
    case last
    case tickets
    
    var buttonTitle: String {
        switch self {
        case .first:
            return "First"
        case .last:
            return "Last"
        case .tickets:
            return "Tickets"
        }
    }
    
}
