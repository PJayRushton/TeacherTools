//
//  ProViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class ProViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var upgradeBorderView: UIView!

    fileprivate var sharedStore = TTProducts.store
    var core = App.core
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsHelper.logEvent(.proLaunched)
        upgradeBorderView.layer.cornerRadius = 5
        upgradeBorderView.backgroundColor = .appleBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func upgradeViewPressed(_ sender: UITapGestureRecognizer) {
        AnalyticsHelper.logEvent(.proPressed)
        core.fire(command: GoPro())
    }

    @IBAction func restoreButtonPressed(_ sender: UIButton) {
        AnalyticsHelper.logEvent(.restorePressed)
        sharedStore.restorePurchases()
    }
    
}


// MARK: - Subscriber

extension ProViewController: Subscriber {
    
    func update(with state: AppState) {
        guard let user = state.currentUser else { return }
        if user.isPro {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
