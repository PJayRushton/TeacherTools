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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
        arrowCompletion?(true)
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
        xButton.setTitleTextAttributes([NSFontAttributeName: theme.font(withSize: 20)], for: .normal)
    }

}


extension GroupListViewController {
    
    func addNewGroup() {
        guard let currentUser = core.state.currentUser else {
            core.fire(event: ErrorEvent(error: nil, message: "Error creating new class"))
            return
        }
        let ref = FirebaseNetworkAccess.sharedInstance.groupsRef(userId: currentUser.id).childByAutoId()
        let newGroupGroups = core.state.groups.filter { $0.name.lowercased().contains("new class") }
        let newGroup = Group(id: ref.key, name: "New Class \(newGroupGroups.count + 1)")
        core.fire(command: CreateGroup(group: newGroup))
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
            let tabBarController = CustomTabBarController.initializeFromStoryboard()
            navigationController?.pushViewController(tabBarController, animated: true)
            dismiss(animated: true, completion: nil)
        case .add:
            if let user = core.state.currentUser, user.isPro || core.state.groups.count == 0 {
                addNewGroup()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                self.dismiss(animated: true, completion: nil)
                self.proCompletion?()
            }
        }
    }
    
}
