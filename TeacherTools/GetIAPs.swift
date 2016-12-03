//
//  GetIAPs.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation
import StoreKit

struct GetIAPs: Command {
    
    enum IAPError: Error {
        case requestError
    }
    
    func execute(state: AppState, core: Core<AppState>) {
        TTProducts.store.requestProducts { success, products in
            if let products = products, success {
                core.fire(event: Updated<[SKProduct]>(products))
            } else {
                core.fire(event: ErrorEvent(error: IAPError.requestError, message: nil))
            }
        }
    }
    
}
