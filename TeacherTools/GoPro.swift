//
//  GoPro.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct GoPro: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        let proProducts = core.state.iaps.filter { $0.productIdentifier == TTProducts.proUpgrade }
        if let proProduct = proProducts.first {
            TTProducts.store.buyProduct(proProduct)
        } else {
            core.fire(event: ErrorEvent(error: nil, message: "Error try again later"))
        }
    }

}
