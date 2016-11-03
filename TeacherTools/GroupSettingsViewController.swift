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
    var group : Group? {
        return core.state.selectedGroup
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isHidden = true
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
        updateSaveButton()
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard var selectedGroup = core.state.selectedGroup, let name = groupNameTextField.text else {
            core.fire(event: ErrorEvent(error: nil, message: "Error saving class"))
            return
        }
        let shouldSave = name.isEmpty == false && name != group?.name
        if shouldSave {
            selectedGroup.name = name
            core.fire(command: UpdateObject(object: selectedGroup))
            core.fire(event: DisplaySuccessMessage(message: "Saved!"))
        } else {
            groupNameTextField.text = group?.name
        }
        endEditing()
    }
    
    
}

extension GroupSettingsViewController: Subscriber {
    
    func update(with state: AppState) {
        groupNameTextField.text = state.selectedGroup?.name
        updateSaveButton()
    }
    
}


extension GroupSettingsViewController {
    
    func toggleSaveButton(hidden: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.saveButton.isHidden = hidden
        }
    }
    
    func updateSaveButton() {
        guard let text = groupNameTextField.text else { return }
        let shouldCancel = text.isEmpty || text == group?.name
        let title = shouldCancel ? "Cancel" : "Save"
        saveButton.setTitle(title, for: .normal)
    }
    
    func endEditing() {
        toggleSaveButton(hidden: true)
        updateSaveButton()
        view.endEditing(true)
    }
    
}

extension GroupSettingsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleSaveButton(hidden: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        toggleSaveButton(hidden: true)
    }
    
}
