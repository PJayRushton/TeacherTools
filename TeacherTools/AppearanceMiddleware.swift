//
//  AppearanceMiddleware.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/7/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

struct AppearanceMiddleware: Middleware {
    
    func process(event: Event, state: AppState) {
        switch event {
        case let event as Updated<Theme>:
            let newTheme = event.payload
            let navTitleAttributes = [NSFontAttributeName: newTheme.font(withSize: 22), NSForegroundColorAttributeName: newTheme.tintColor]
            UINavigationBar.appearance().titleTextAttributes = navTitleAttributes
            UINavigationBar.appearance().backgroundColor = UIColor.clear
            UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = newTheme.tintColor
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationController.self]).setTitleTextAttributes([NSFontAttributeName: newTheme.font(withSize: 17)], for: .normal)
            UINavigationBar.appearance().isTranslucent = true
        default:
            break
        }
    }
    
}
