//
//  AppDelegate.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var core = App.core
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        core.fire(command: GetICloudUser())
        
        if !Platform.isSimulator {
//            FIRDatabase.database().persistenceEnabled = true
        }
        FIRDatabase.database().persistenceEnabled = true
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if core.state.currentUser == nil {
            core.fire(command: GetICloudUser())
        }
        if let mainVC = application.topViewController() as? MainViewController {
            mainVC.loadingImageVC.appleImageView.rotate()
        }
    }

}
