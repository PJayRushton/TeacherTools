//
//  Arrays.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

extension Collection where Iterator.Element: Identifiable {
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        for element in self {
            json[element.id] = true
        }
        return json
    }
    
}

extension Sequence where Iterator.Element == StringLiteralType {
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        for value in self {
            json[value] = true
        }
        return json
    }
}

extension UIViewController {
    
    var embededInNavigationController: UINavigationController {
        return UINavigationController(rootViewController: self)
    }
    
}
