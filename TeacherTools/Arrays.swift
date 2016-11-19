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

let array = [1,2,3,4,5,6]
let steps = array.step(from: array.startIndex, to:array.endIndex, interval: 2)

extension MutableCollection where Indices.Iterator.Element == Index {
    
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        guard count > 1 else { return }
        
        for (unshuffledCount, firstUnshuffled) in zip(stride(from: count, to: 1, by: -1), indices) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension Int {
    
    static func random(_ range: Range<Int>) -> Int {
        return range.lowerBound + (Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound))))
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

extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: M_PI * 2)
        rotation.duration = 0.5
        rotation.isCumulative = true
        rotation.repeatCount = 2
        layer.add(rotation, forKey: "rotationAnimation")
    }
}
