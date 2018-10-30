//
//  GroupListViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class GroupListViewController: UIViewController, AutoStoryboardInitializable {

    @IBOutlet weak var xButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var core = App.core
    var groups: [Group] {
        return core.state.groups.sorted { $0.name < $1.name }
    }
    var proCompletion: (() -> Void)?
    var arrowCompletion: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: view.bounds.width * 0.6, height: view.bounds.height * 0.6)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
        arrowCompletion?(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if core.state.groups.isEmpty {
            presentNewGroupAlert()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
        arrowCompletion?(false)
    }

    @IBAction func xButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - Subscriber

extension GroupListViewController: Subscriber {
    
    func update(with state: AppState) {
        updateUI(with: state.theme)
        tableView.reloadData()
    }
    
    func updateUI(with theme: Theme) {
        tableView.backgroundView = theme.mainImage.imageView
        let borderImage = theme.borderImage.image.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationController?.navigationBar.setBackgroundImage(borderImage, for: .default)
        xButton.tintColor = theme.textColor
        xButton.setTitleTextAttributes([NSAttributedString.Key.font: theme.font(withSize: 20)], for: .normal)
    }

}


extension GroupListViewController {
    
    func presentNewGroupAlert() {
        let alert = UIAlertController(title: "New Class", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alert.textFields?.first, let groupName = textField.text else { return }
            self.saveNewGroup(withName: groupName)
        }
        
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("Enter class name", comment: "Placeholder to enter class name")
            textField.autocapitalizationType = .words
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: { _ in
                saveAction.isEnabled = textField.text != nil && !textField.text!.isEmpty
            })
            
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func saveNewGroup(withName name: String) {
        core.fire(command: CreateGroup(name: name))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) { 
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}


// MARK: - TableView

extension GroupListViewController: UITableViewDataSource, UITableViewDelegate {
    
    enum TableSection: Int {
        case groupList
        case add
        
        static let allValues = [TableSection.groupList, .add]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.allValues.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSection(rawValue: section)! {
        case .groupList:
            return groups.count
        case .add:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TableSection(rawValue: indexPath.section)! {
        case .groupList:
            let cell = tableView.dequeueReusableCell(withIdentifier: GroupTableViewCell.reuseIdentifier) as! GroupTableViewCell
            let groupAtRow = groups[indexPath.row]
            cell.update(with: groupAtRow, theme: core.state.theme, isSelected: core.state.selectedGroup == groupAtRow)
            
            return cell
        case .add:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddGroupTableCell.reuseIdentifier) as! AddGroupTableCell
            cell.update(with: core.state.theme)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch TableSection(rawValue: indexPath.section)! {
        case .groupList:
            core.fire(event: Selected<Group>(groups[indexPath.row]))
            dismiss(animated: true, completion: nil)
        case .add:
            if let user = core.state.currentUser, user.isPro || core.state.groups.count == 0 {
                presentNewGroupAlert()
            } else {
                self.dismiss(animated: true, completion: nil)
                self.proCompletion?()
            }
        }
    }
    
}
