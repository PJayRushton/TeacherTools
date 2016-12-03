//
//  ProViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class ProViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var upgradeButton: UIButton!

    var core = App.core
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = core.state.currentUser, currentUser.isPro == false else {
            upgradeButton.isEnabled = false
            return
        }
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

    @IBAction func upgradeButtonPressed(_ sender: UIButton) {
        core.fire(command: GoPro())
    }
    
}


// MARK: - Subscriber

extension ProViewController: Subscriber {
    
    func update(with state: AppState) {
        guard let user = state.currentUser else { return }
        let title = user.isPro ? "Thanks for support Teacher Tools!" : "Upgrade to Pro\n($1.99)"
        upgradeButton.setTitle(title, for: .normal)
    }
    
}
