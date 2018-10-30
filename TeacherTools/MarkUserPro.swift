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
        UserDefaults.standard.userIsPro = true
        guard let currentUser = core.state.currentUser, !currentUser.isPro else { return }
        let newPurchaseRef = currentUser.ref.child("purchases").childByAutoId()
        guard let key = newPurchaseRef.key else { return }
        let proPurchase = TTPurchase(id: key, productId: TTProducts.proUpgrade, purchaseDate: Date())
        newPurchaseRef.updateChildValues(proPurchase.jsonObject())
    }
    
}

extension UserDefaults {
    
    var userIsPro: Bool {
        get {
            return bool(forKey: #function)
        }
        set {
            set(newValue, forKey: #function)
            synchronize()
        }
    }
}
