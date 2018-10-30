//
//  Arrays.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

extension Collection where Self: ExpressibleByDictionaryLiteral, Self.Key == String, Self.Value == Any {
    
    func parsedObjects<T: Identifiable>() -> [T] {
        guard let json = self as? JSONObject else { return [] }
        let keys = Array(json.keys)
        let objects: [JSONObject] = keys.compactMap { try? json.value(for: $0) }
        return objects.compactMap { try? T(object: $0) }
    }

}

extension Optional where Wrapped: MarshaledObject {
    
    func parsedObjects<T: Identifiable>() -> [T] {
        guard let json = self as? JSONObject else { return [] }
        let keys = Array(json.keys)
        let objects: [JSONObject] = keys.compactMap { try? json.value(for: $0) }
        return objects.compactMap { try? T(object: $0) }
    }
    
}

extension Collection where Element: Identifiable {
    
    func jsonObject() -> JSONObject {
        var json = JSONObject()
        for element in self {
            json[element.id] = element.jsonObject()
        }
        
        return json
    }
    
}

extension Array {
    
    func step(from: Index, to:Index, interval: Int = 1) -> Array<Element> {
        let strde = stride(from: from, to: to, by: interval)
        var arr = Array<Element>()
        for i in strde {
            arr.append(self[i])
        }
        return arr
    }
    
}

extension Sequence where Iterator.Element == StringLiteralType {
    
    func jsonObject() -> JSONObject {
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

extension UIView {
    
    func rotate(duration: CFTimeInterval = 2, count: Float = Float.greatestFiniteMagnitude) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = count
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
}
