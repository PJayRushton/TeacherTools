//
//  GroupSettingsViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/1/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class GroupSettingsViewController: UIViewController, AutoStoryboardInitializable {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var core = App.core
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        let title = text.isEmpty ? "Cancel" : "Save"
        saveButton.setTitle(title, for: .normal)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard var selectedGroup = core.state.selectedGroup, let name = groupNameTextField.text else {
            core.fire(event: ErrorEvent(error: nil, message: "Error saving class"))
            return
        }
        let isSave = name.isEmpty == false
        if isSave {
            selectedGroup.name = name
            core.fire(command: UpdateObject(object: selectedGroup))
            core.fire(event: DisplaySuccessMessage(message: "Saved!"))
        } else {
            core.fire(event: ErrorEvent(error: nil, message: "Its gotta be named SOMETHING"))
        }
    }
    
    
}

extension GroupSettingsViewController: Subscriber {
    
    func update(with state: AppState) {
        groupNameTextField.text = state.selectedGroup?.name
    }
    
}


extension GroupSettingsViewController {
    
    func toggleSaveButton(hidden: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.saveButton.isHidden = hidden
        }
    }
    
}
