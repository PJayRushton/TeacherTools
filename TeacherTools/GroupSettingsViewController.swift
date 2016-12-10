//
//  GroupSettingsViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/1/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class GroupSettingsViewController: UIViewController, AutoStoryboardInitializable {

    // MARK: - IBOutlets

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var displayNamesLabel: UILabel!
    @IBOutlet weak var segmentedControl: BetterSegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    
    var core = App.core
    var group : Group? {
        return core.state.selectedGroup
    }
    fileprivate let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id977797579")
    
    
    // MARK: - ViewController Lifecycle

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
    

    // MARK: - IBActions

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        updateSaveButton()
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveClassName()
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

    @IBAction func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        var updatedTheme = core.state.theme
        updatedTheme.lastFirst = Int(sender.index) == NameDisplayType.lastFirst.rawValue
        core.fire(command: UpdateTheme(theme: updatedTheme))
    }
    
    @IBAction func rateButtonPressed(_ sender: UIButton) {
        launchAppStore()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        launchShareSheet()
    }
    
    @IBAction func proButtonPressed(_ sender: UIButton) {
        let proVC = ProViewController.initializeFromStoryboard().embededInNavigationController
        present(proVC, animated: true, completion: nil)
    }
    
}

extension GroupSettingsViewController: Subscriber {
    
    func update(with state: AppState) {
        groupNameTextField.text = state.selectedGroup?.name
        updateSaveButton()
        updateUI(with: state.theme)
    }
    
}


// MARK: - Fileprivate

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
    
    func saveClassName() {
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
        var message = "This cannot be undone"
        if group.studentIds.count > 0 {
            let studentKey = group.studentIds.count == 1 ? "student" : "students"
            message = "\nThis class's \(group.studentIds.count) \(studentKey) will also be deleted."
        }
        let alert = UIAlertController(title: "Are you sure?", message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.core.fire(command: DeleteObject(object: group))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func updateUI(with theme: Theme) {
        groupNameTextField.font = theme.font(withSize: 17)
        saveButton.titleLabel?.font = theme.font(withSize: 15)
        saveButton.titleLabel?.textColor = theme.tintColor
        updateSegmentedControl(theme: theme)
    }
    
    func launchAppStore() {
        guard let appStoreURL = appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) else {
            core.fire(event: ErrorEvent(error: nil, message: "Error launching app store"))
            return
        }
        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
    }
    
    func launchShareSheet() {
        let textToShare = "Check out this great app for teachers called Teacher Tools. You can find it in the app store!"
        var objectsToShare: [Any] = [textToShare]
        
        if let appStoreURL = URL(string: "https://itunes.apple.com/us/app/teacher-tools-tool-for-teachers/id977797579?mt=8") {
            objectsToShare.append(appStoreURL)
        }
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, .addToReadingList, .assignToContact, .openInIBooks, .postToTencentWeibo, .postToVimeo, .print, .saveToCameraRoll, .postToWeibo, .postToFlickr]
        present(activityVC, animated: true, completion: nil)
    }
    
}


// MARK: - TextFieldDelegate

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


// MARK: - SegmentedControl

extension GroupSettingsViewController {
    
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
    
    func updateSegmentedControl(theme: Theme) {
        segmentedControl.titles = NameDisplayType.allValues.map { $0.displayString }
        segmentedControl.backgroundColor = .white // FIXME:
        segmentedControl.titleColor = theme.textColor
        segmentedControl.titleFont = theme.font(withSize: 16)
        segmentedControl.selectedTitleFont = theme.font(withSize: 18)
        segmentedControl.indicatorViewBackgroundColor = theme.tintColor
        segmentedControl.cornerRadius = 5
    }
    
}
