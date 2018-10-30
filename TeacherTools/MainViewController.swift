//
//  MainViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//               ...

import UIKit

class MainViewController: UIViewController {

    var core = App.core
    
    let tabBarViewController = MainTabBarController.initializeFromStoryboard()
    let loadingImageVC = LoadingImageViewController.initializeFromStoryboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        core.fire(command: SubscribeToThemes())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
    }
    
}


extension MainViewController: Subscriber {
    
    func update(with state: AppState) {
        if let _ = state.currentUser, state.groupsAreLoaded {
            presentApplication()
        } else {
            showLoadingScreen()
        }
    }
    
}


extension MainViewController {
    
    fileprivate func presentApplication() {
        if tabBarViewController.parent == nil {
            loadingImageVC.removeFromParent()
            loadingImageVC.view.removeFromSuperview()
            
            tabBarViewController.selectedIndex = 0
            addChild(tabBarViewController)
            view.addSubview(tabBarViewController.view)
        }
    }

    fileprivate func showLoadingScreen() {
        tabBarViewController.removeFromParent()
        if let index = view.subviews.index(of: loadingImageVC.view) {
            view.bringSubviewToFront(view.subviews[index])
        } else {
            addChild(loadingImageVC)
            view.addSubview(loadingImageVC.view)
        }
    }
    
}
