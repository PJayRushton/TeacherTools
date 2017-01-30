//
//  Theme.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import Firebase

enum BackgroundImage: String {
    case white, black, greenChalkboard, blackChalkboard
    
    var imageView: UIImageView {
        return UIImageView(image: image)
    }
    var image: UIImage {
        return UIImage(named: rawValue)!
    }
    
}

enum Banner: String {
    case wood, lightWood, darkWood, metal
    
    var image: UIImage {
        return UIImage(named: rawValue)!
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

struct Theme: Marshaling {
    
    var id: String
    var name: String
    var mainImage: BackgroundImage
    var borderImage: Banner
    var tintColor: UIColor
    var textColor: UIColor
    fileprivate var fontType: FontType
    var isDefault: Bool
    
    var plusButtonSize: CGFloat {
        return 32.0
    }
    var isLocked: Bool {
        if isDefault {
            return false
        }
        guard let currentUser = App.core.state.currentUser else { return true }
        return !currentUser.isPro
    }

    init(id: String = "", name: String = "", mainImage: BackgroundImage, borderImage: Banner, tintColor: UIColor, textColor: UIColor, fontType: FontType, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.mainImage = mainImage
        self.borderImage = borderImage
        self.tintColor = tintColor
        self.textColor = textColor
        self.fontType = fontType
        self.isDefault = isDefault
    }
    
    func font(withSize size: CGFloat) -> UIFont {
        return fontType.font(withSize: size)
    }
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        json["id"] = id
        json["name"] = name
        json["mainImage"] = mainImage.rawValue
        json["borderImage"] = borderImage.rawValue
        json["tintColor"] = tintColor.hexValue
        json["textColor"] = textColor.hexValue
        json["fontType"] = fontType.rawValue
        json["isDefault"] = isDefault
        
        return json
    }
    
}

extension Theme: Identifiable {
    
    var ref: FIRDatabaseReference {
        return FirebaseNetworkAccess.sharedInstance.allThemesRef.child(id)
    }
    
}

extension Theme: Equatable { }
func ==(lhs: Theme, rhs: Theme) -> Bool {
    return lhs.mainImage == rhs.mainImage &&
        lhs.borderImage == rhs.borderImage &&
        lhs.tintColor == rhs.tintColor &&
        lhs.textColor == rhs.textColor
}

extension Theme: Unmarshaling {
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        name = try object.value(for: "name")
        mainImage = try object.value(for: "mainImage")
        borderImage = try object.value(for: "borderImage")
        tintColor = try object.value(for: "tintColor")
        textColor = try object.value(for: "textColor")
        fontType = try object.value(for: "fontType")
        isDefault = try object.value(for: "isDefault")
    }
    
}

var defaultTheme: Theme {
    return whiteTheme
}
fileprivate let whiteTheme = Theme(mainImage: .white, borderImage: .metal, tintColor: .appleBlue, textColor: .darkGray, fontType: .chalkBoard, isDefault: true)
