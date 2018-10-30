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
        let navTitleAttributes = [NSAttributedString.Key.font: theme.font(withSize: 22), NSAttributedString.Key.foregroundColor: theme.textColor]
        UINavigationBar.appearance().titleTextAttributes = navTitleAttributes
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).tintColor = theme.textColor
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: theme.font(withSize: 17)], for: .normal)
        UINavigationBar.appearance().isTranslucent = true
        let appearance = UITabBarItem.appearance()
        let fontSize = UIFont.preferredFont(forTextStyle: .caption2).pointSize
        let font = theme.font(withSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        appearance.setTitleTextAttributes(attributes, for: .normal)
    }
    
}
