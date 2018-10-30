//
//  AddStudentsViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/31/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, AutoStoryboardInitializable {
    
    enum Tab: Int, CaseIterable {
        case list
        case groups
        case drawName
        case settings
    }
    

    // MARK: - Properties
    
    var core = App.core
    
    
    // MARK: - Lifecycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
    }
    
}

// MARK: - Subscriber

extension MainTabBarController: Subscriber {
    
    func update(with state: AppState) {
        let currentTheme = state.theme
        tabBar.tintColor = currentTheme.tintColor
        tabBar.unselectedItemTintColor = currentTheme.textColor
    }
    
}


// MARK: - Private functions

private extension MainTabBarController {
    
}
