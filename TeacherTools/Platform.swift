//
//  Platform.swift
//  TeacherTools
//
//  Created by Parker Rushton on 5/6/17.
//  Copyright © 2017 AppsByPJ. All rights reserved.
//

import UIKit

struct Platform {
    
    @nonobjc static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
}
