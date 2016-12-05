//
//  Theme.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

struct Theme {
    
    var mainImage: UIImage
    var borderImage: UIImage
    var tintColor: UIColor
    var textColor: UIColor
    var fontType: FontType
    var lastFirst: Bool
    
    func font(withSize size: CGFloat) -> UIFont {
        return fontType.font(withSize: size)
    }
    
}

let defaultTheme = Theme(mainImage: BackgroundImage.white.image, borderImage: Border.wood.image, tintColor: .blue, textColor: .darkGray, fontType: .chalkDuster, lastFirst: false)

enum BackgroundImage {
    case white, black, greenChalkboard, blackChalkboard
    
    var image: UIImage {
        switch self {
        case .white:
            return UIImage(named: "white")!
        case .black:
            return UIImage(named: "black")!
        case .greenChalkboard:
            return UIImage(named: "greenChalkboard")!
        case .blackChalkboard:
            return UIImage(named: "blackChalkboard")!
        }
    }
    
}

enum Banner {
    case wood, lightWood, darkWood
    case metal
    
    var image: UIImage {
        switch self {
        case .wood:
            return UIImage(named: "wood")!
        case .lightWood:
            return UIImage(named: "lightWood")!
        case .darkWood:
            return UIImage(named: "darkWood")!
//        case .metal:
//            return UIImage(named: "white")!
        }
        
    }
}

enum FontType: String {
    case chalkDuster = "Chalkduster"
    case chalkBoard = "ChalkboardSE-Light"
    case bradley = "BradleyHandITCTT-Bold"
    case futura = "Futura-Medium"
    
    func font(withSize size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
    
}
