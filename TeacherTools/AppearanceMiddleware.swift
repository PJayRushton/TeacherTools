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
        let newTheme = state.theme
        let navTitleAttributes = [NSFontAttributeName: newTheme.font(withSize: 22), NSForegroundColorAttributeName: newTheme.textColor]
        UINavigationBar.appearance().titleTextAttributes = navTitleAttributes
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = newTheme.tintColor
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: newTheme.font(withSize: 17)], for: .normal)
        UINavigationBar.appearance().isTranslucent = true
        let isWhiteStatus = newTheme.textColor == .white
        UIApplication.shared.statusBarStyle = isWhiteStatus ? .lightContent : .default
    }
    
}
