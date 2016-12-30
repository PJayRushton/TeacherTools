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
        case let event as Updated<[Theme]>:
            guard let user = state.currentUser else { return }
            let newTheme = event.payload.filter { $0.id == user.themeID }.first
            if let newTheme = newTheme {
                updateUI(with: newTheme)
            }
        case let event as Selected<User>:
            let selectedTheme = state.allThemes.filter { $0.id == event.item?.themeID }.first
            if let newTheme = selectedTheme {
                updateUI(with: newTheme)
            }
        default:
            break
        }
    }
    
    func updateUI(with theme: Theme) {
        let navTitleAttributes = [NSFontAttributeName: theme.font(withSize: 22), NSForegroundColorAttributeName: theme.textColor]
        UINavigationBar.appearance().titleTextAttributes = navTitleAttributes
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = theme.textColor
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: theme.font(withSize: 17)], for: .normal)
        UINavigationBar.appearance().isTranslucent = true
        let isWhiteStatus = theme.textColor == .white
        UIApplication.shared.statusBarStyle = isWhiteStatus ? .lightContent : .default
    }
    
}
