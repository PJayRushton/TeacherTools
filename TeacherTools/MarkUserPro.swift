//
//  MarkUserPro.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import Foundation

struct MarkUserPro: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let currentUser = core.state.currentUser, currentUser.isPro == false else { return }
        let newPurchaseRef = currentUser.ref.child("purchases").childByAutoId()
        let proPurchase = TTPurchase(id: newPurchaseRef.key, productId: TTProducts.proUpgrade, purchaseDate: Date())
        newPurchaseRef.updateChildValues(proPurchase.marshaled())
    }
    
}
