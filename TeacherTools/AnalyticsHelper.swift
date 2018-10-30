//
//  AnalyticsHelper.swift
//  TeacherTools
//
//  Created by Parker Rushton on 5/6/17.
//  Copyright © 2017 AppsByPJ. All rights reserved.
//

import Foundation
import Firebase

enum AnalyticsEventName: String {
    //Purchases
    case proLaunched
    case proPressed
    case restorePressed
    case proPurchased
    case proRestored
    case productRequestFailure
    case productPurchaseFailure
    case productRestoreFailiure
    
    // Usage
    case teamDensityAltered
    case nameDrawUsed
    case classPasteViewed
    case classPasteUsed
    case themeChanged
    case themeChangeAttempt
}


struct AnalyticsHelper {
    
    static func logEvent(_ name: AnalyticsEventName) {
        guard !Platform.isSimulator else { return }
        Analytics.logEvent(name.rawValue, parameters: nil)
    }
    
}
