//
//  StoryboardInitializable.swift
// Amanda's Recipes
//
//  Created by Ben Norris on 4/12/16.
//  Copyright © 2016 OC Tanner. All rights reserved.
//

import UIKit

protocol StoryboardInitializable {
    static var storyboardName: String { get }
    static var viewControllerIdentifier: String { get }
    static func initializeFromStoryboard() -> Self
}

extension StoryboardInitializable {
    
    static func initializeFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? Self else {
            fatalError("Error instantiating \(self) from storyboard")
        }
        return vc
    }
    
}

/// Uses the class name for the storyboard name and the viewcontroller identifier. Provides *initializeWithStoryboard* function
protocol AutoStoryboardInitializable { }

extension AutoStoryboardInitializable {
    
    static func initializeFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: String(describing: Self.self), bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: String(describing: Self.self)) as? Self else {
            fatalError("Error instantiating \(self) from storyboard")
        }
        return vc
    }
    
}

///Uses a UITableViewCell's class name as its *reuseIdentifier* property
/// - returns: *reuseIdentifer* (String) available to any conforming UITableViewCell. **Don't forget to set the reuseIdentifer in the storyboard**
protocol AutoReuseIdentifiable { }

extension AutoReuseIdentifiable {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}
