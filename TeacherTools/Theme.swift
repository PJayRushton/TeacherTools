//
//  Theme.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

struct Theme {
    
    var mainColor: UIColor
    var tintColor: UIColor
    var textColor: UIColor
    var fontType: FontType
    
}

enum FontType {
    case chalkDuster = "Chalkduster"
    case appleSD = "AppleSDGothicNeo-Regular"
    
    func font(withSize size: CGFloat) -> UIFont {
        return UIFont(name: <#T##String#>, size: <#T##CGFloat#>)
    }
    
}
