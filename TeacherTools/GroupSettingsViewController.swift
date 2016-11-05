//
//  GroupSettingsViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/1/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import SJFluidSegmentedControl

class GroupSettingsViewController: UIViewController, AutoStoryboardInitializable {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var fluidSegmentedControl: SJFluidSegmentedControl!
    
    var core = App.core
    var group : Group? {
        return core.state.selectedGroup
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isHidden = true
        fluidSegmentedControl.shapeStyle = .liquid
        fluidSegmentedControl.cornerRadius = fluidSegmentedControl.bounds.height / 2
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
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        if let group = group {
            if core.state.groups.count == 1 {
                presentNoDeleteAlert()
            } else {
                presentDeleteConfirmation(for: group)
            }
        } else {
            core.fire(event: ErrorEvent(error: nil, message: "Unable to delete class"))
        }
    }
    
}

extension GroupSettingsViewController: Subscriber {
    
    func update(with state: AppState) {
        groupNameTextField.text = state.selectedGroup?.name
        updateSaveButton()
        fluidSegmentedControl.textFont = state.theme.fontType.font(withSize: 18)
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
    
    func presentNoDeleteAlert() {
        let alert = UIAlertController(title: "You won't have any classes left!", message: "You'll have to add a new class first", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentDeleteConfirmation(for group: Group) {
        let alert = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.core.fire(command: DeleteObject(object: group))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension GroupSettingsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        toggleSaveButton(hidden: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        toggleSaveButton(hidden: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveButtonPressed(saveButton)
        return true
    }
    
}

extension GroupSettingsViewController: SJFluidSegmentedControlDelegate, SJFluidSegmentedControlDataSource {
    
    enum NameDisplayType: Int {
        case firstLast
        case lastFirst
        
        var displayString: String {
            switch self {
            case .firstLast:
                return "First Last"
            case .lastFirst:
                return "Last, First"
            }
        }
        
        static let allValues = [NameDisplayType.firstLast, .lastFirst]
    }
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return NameDisplayType.allValues.count
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, titleForSegmentAtIndex index: Int) -> String? {
        return NameDisplayType.allValues[index].displayString
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didChangeFromSegmentAtIndex fromIndex: Int, toSegmentAtIndex toIndex: Int) {
        core.fire(event: NameDisplayChanged(lastFirst: toIndex == NameDisplayType.lastFirst.rawValue))
    }
    
}
