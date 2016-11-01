//
//  GroupListViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import Whisper

class GroupListViewController: UIViewController, AutoStoryboardInitializable {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIBarButtonItem!
    @IBOutlet weak var newEntryView: UIView!
    @IBOutlet weak var newGroupTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var core = App.core
    let maxGroupNameCharacterCount = 50
    var initialLoadingIsFinished = false
    var groups: [Group] {
        return core.state.groups.sorted { $0.lastViewDate < $1.lastViewDate }
    }
    var isAdding = false {
        didSet {
            toggleEntryView(hidden: !isAdding)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
        core.fire(event: DisplayNavBarMessage(nav: navigationController!, message: "Loading your classes...", barColor: core.state.theme.tintColor.withAlphaComponent(0.7), time: nil))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
    }
    
    @IBAction func plusButtonPressed(_ sender: UIBarButtonItem) {
        isAdding = true
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveNewGroup()
    }
    
    @IBAction func newGroupTextFieldChanged(_ sender: UITextField) {
        let title = sender.text!.isEmpty ? "Cancel" : "Save"
        saveButton.setTitle(title, for: .normal)
    }
    
    func loadTestData() {
        core.fire(command: LoadFakeUser())
        core.fire(command: LoadFakeStudents())
        core.fire(command: LoadFakeGroups())
    }

}


// MARK: - Subscriber

extension GroupListViewController: Subscriber {
    
    func update(with state: AppState) {
        tableView.reloadData()
        
        if state.groupsAreLoaded && initialLoadingIsFinished == false {
            initialLoadingIsFinished = true
            hide(whisperFrom: navigationController!)
        }
    }
    
}

fileprivate extension GroupListViewController {
    
    func setUp() {
        newEntryView.isHidden = true
        tableView.rowHeight = 80.0
        plusButton.tintColor = core.state.theme.tintColor
        
        let gr = UITapGestureRecognizer()
        gr.numberOfTapsRequired = 3
        gr.addTarget(self, action: #selector(loadTestData))
        navigationController?.navigationBar.addGestureRecognizer(gr)
    }
    
    func toggleEntryView(hidden: Bool) {
        UIView.animate(withDuration: 0.5, animations: { 
            self.newEntryView.isHidden = hidden
            DispatchQueue.main.async {
                if hidden {
                    self.newGroupTextField.resignFirstResponder()
                } else {
                    self.newGroupTextField.becomeFirstResponder()
                }
            }
        }) { _ in
            self.newGroupTextField.text = ""
        }
    }
    
    func saveNewGroup() {
        if let newGroupName = newGroupTextField.text, newGroupName.isEmpty == false {
            let newGroup = Group(name: newGroupName)
            core.fire(command: CreateObject(object: newGroup))
        }
        isAdding = false
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


// MARK: - TableView

extension GroupListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.reuseIdentifier) as! GroupTableViewCell
        cell.update(with: groups[indexPath.row], theme: core.state.theme)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        core.fire(event: Selected<Group>(groups[indexPath.row]))
        let toolsVC = ToolsViewController.initializeFromStoryboard()
        navigationController?.pushViewController(toolsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let groupAtRow = groups[indexPath.row]
        presentDeleteConfirmation(for: groupAtRow)
    }
    
}


// MARK: - Textfield Delegate

extension GroupListViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let stringLength = textField.text!.characters.count + string.characters.count - range.length
        return stringLength < maxGroupNameCharacterCount
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveNewGroup()
        return true
    }
    
}
