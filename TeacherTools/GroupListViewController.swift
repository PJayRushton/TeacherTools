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
    
    var core = App.core
    var groups: [Group] {
        return core.state.groups.sorted { $0.lastViewDate > $1.lastViewDate }
    }
    
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

}


// MARK: - Subscriber

extension GroupListViewController: Subscriber {
    
    func update(with state: AppState) {
        tableView.reloadData()
        preferredContentSize = CGSize(width: 0, height: tableView.contentSize.height)
    }

}


extension GroupListViewController {
    
    func addNewGroup() {
        guard let currentUser = core.state.currentUser else {
            core.fire(event: ErrorEvent(error: nil, message: "Error creating new group"))
            return
        }
        let id = FirebaseNetworkAccess.sharedInstance.groupsRef(userId: currentUser.id).childByAutoId()
        let newGroupGroups = core.state.groups.filter { $0.name.lowercased().contains("new group") }
        let newGroup = Group(id: id.key, name: "New Group \(newGroupGroups.count + 1)")
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
            addNewGroup()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
}
