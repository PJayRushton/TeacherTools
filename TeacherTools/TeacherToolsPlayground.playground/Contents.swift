//: Playground - noun: a place where people can play

import UIKit

extension UIColor {
    
    class var ticketRed: UIColor { return #colorLiteral(red: 0.9876169562, green: 0.4118406773, blue: 0.4343959093, alpha: 1) }
    
    enum ColorError: Error {
        case bad
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
            throw ColorError.bad
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

let color1 = try! UIColor(hex: "#707969")
let hex = color1.hexValue
