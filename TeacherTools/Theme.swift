//
//  Theme.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import Firebase
import Marshal

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

struct Theme {
    
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
        let adjustedSize = Platform.isPad ? size * 1.3 : size
        return fontType.font(withSize: adjustedSize)
    }
    
}


// MARK: - Identifiable

extension Theme: Identifiable {
    
    var ref: DatabaseReference {
        return FirebaseNetworkAccess.sharedInstance.allThemesRef.child(id)
    }
    
}


// MARK: - Unmarshaling

extension Theme: Unmarshaling {
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: Keys.id)
        name = try object.value(for: Keys.name)
        mainImage = try object.value(for: Keys.mainImage)
        borderImage = try object.value(for: Keys.borderImage)
        tintColor = try object.value(for: Keys.tintColor)
        textColor = try object.value(for: Keys.textColor)
        fontType = try object.value(for: Keys.fontType)
        isDefault = try object.value(for: Keys.isDefault)
    }
    
}


// MARK: - Marshaling

extension Theme: JSONMarshaling {
    
    func jsonObject() -> JSONObject {
        var json = JSONObject()
        json[Keys.id] = id
        json[Keys.name] = name
        json[Keys.mainImage] = mainImage.rawValue
        json[Keys.borderImage] = borderImage.rawValue
        json[Keys.tintColor] = tintColor.hexValue
        json[Keys.textColor] = textColor.hexValue
        json[Keys.fontType] = fontType.rawValue
        json[Keys.isDefault] = isDefault
        
        return json
    }
    
}


// MARK: - Equatable

extension Theme: Equatable { }

func ==(lhs: Theme, rhs: Theme) -> Bool {
    return lhs.mainImage == rhs.mainImage &&
        lhs.borderImage == rhs.borderImage &&
        lhs.tintColor == rhs.tintColor &&
        lhs.textColor == rhs.textColor
}


var defaultTheme: Theme {
    return whiteTheme
}

fileprivate let whiteTheme = Theme(mainImage: .white, borderImage: .metal, tintColor: .appleBlue, textColor: .darkGray, fontType: .chalkBoard, isDefault: true)
