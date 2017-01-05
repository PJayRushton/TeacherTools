//
//  UIColorExtension.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/1/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var ticketRed: UIColor { return #colorLiteral(red: 0.9882352941, green: 0.4117647059, blue: 0.4352941176, alpha: 1) }
    class var coolBlue: UIColor {
        return try! UIColor(hex: "4DA6BD")
    }
    
    class var appleBlue: UIColor {
        return try! UIColor(hex: "007AFF")
    }
    
    class var chalk: UIColor {
        return try! UIColor(hex: "FFFFDC")
    }
    
    convenience init(hex hexString: String) throws {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            throw MarshalError.nullValue(key: hexString)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    var hexValue: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb = (Int)(red * 255)<<16 | (Int)(green * 255)<<8 | (Int)(blue * 255)<<0
        
        return String(format:"#%06x", rgb)
    }
    
}

extension MarshaledObject {
    
    public func value(for key: KeyType) throws -> UIColor {
        do {
            let stringValue: String = try self.value(for: key)
            return try UIColor(hex: stringValue)
        } catch MarshalError.nullValue {
            throw MarshalError.nullValue(key: key)
        }
    }
    
}
