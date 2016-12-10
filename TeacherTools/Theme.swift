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
    
    var image: UIImage {
        return UIImage(named: rawValue)!
    }
    
}

enum Banner: String {
    case wood, lightWood, darkWood
    //    case metal
    
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
    var mainImage: BackgroundImage
    var borderImage: Banner
    var tintColor: UIColor
    var textColor: UIColor
    fileprivate var fontType: FontType
    var lastFirst: Bool
    var isDefault: Bool
    
    var isLocked: Bool {
        if isDefault {
            return false
        }
        guard let currentUser = App.core.state.currentUser else { return true }
        return !currentUser.isPro
    }

    init(id: String = "", mainImage: BackgroundImage, borderImage: Banner, tintColor: UIColor, textColor: UIColor, fontType: FontType, lastFirst: Bool = false, isDefault: Bool = false) {
        self.id = id
        self.mainImage = mainImage
        self.borderImage = borderImage
        self.tintColor = tintColor
        self.textColor = textColor
        self.fontType = fontType
        self.lastFirst = lastFirst
        self.isDefault = isDefault
    }
    
    func font(withSize size: CGFloat) -> UIFont {
        return fontType.font(withSize: size)
    }
    
    func marshaled() -> JSONObject {
        var json = JSONObject()
        json["id"] = id
        json["mainImage"] = mainImage.rawValue
        json["borderImage"] = borderImage.rawValue
        json["tintColor"] = tintColor.hexValue
        json["textColor"] = textColor.hexValue
        json["fontType"] = fontType.rawValue
        json["lastFirst"] = lastFirst
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
        mainImage = try object.value(for: "mainImage")
        borderImage = try object.value(for: "borderImage")
        tintColor = try object.value(for: "tintColor")
        textColor = try object.value(for: "textColor")
        fontType = try object.value(for: "fontType")
        lastFirst = try object.value(for: "lastFirst")
        isDefault = try object.value(for: "isDefault")
    }
    
}

let whiteTheme = Theme(mainImage: .white, borderImage: .wood, tintColor: .blue, textColor: .darkGray, fontType: .chalkBoard, isDefault: true)
let darkTheme = Theme(mainImage: .black, borderImage: .darkWood, tintColor: .coolBlue, textColor: .white, fontType: .futura)
let greenTheme = Theme(mainImage: .greenChalkboard, borderImage: .wood, tintColor: .white, textColor: .white, fontType: .chalkDuster)
let blackTheme = Theme(mainImage: .blackChalkboard, borderImage: .lightWood, tintColor: .white, textColor: .white, fontType: .bradley)
