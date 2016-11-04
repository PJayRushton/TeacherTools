//
//  StudentListViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/31/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController, AutoStoryboardInitializable {

    @IBOutlet weak var navBarButton: NavBarButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var newEntryView: UIView!
    @IBOutlet weak var newStudentTextField: UITextField!

    var core = App.core
    var group: Group?
    var students = [Student]()
    
    fileprivate var plusBarButton = UIBarButtonItem()
    fileprivate var saveBarButton = UIBarButtonItem()
    fileprivate var cancelBarButton = UIBarButtonItem()
    var isAdding = false {
        didSet {
            toggleEntryView(hidden: !isAdding)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        newEntryView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
    }
    
    @IBAction func plusButtonPressed(_ sender: UIBarButtonItem) {
        isAdding = true
    }
    
    @IBAction func newStudentTextFieldChanged(_ sender: UITextField) {
        navigationItem.rightBarButtonItem = sender.text!.isEmpty ? cancelBarButton : saveBarButton
    }
    
}


// MARK: - Subscriber

extension StudentListViewController: Subscriber {
    
    func update(with state: AppState) {
        if let group = state.selectedGroup {
            self.group = group
            navBarButton.mainTitle = group.name
            navBarButton.subTitle = "\(group.students.count) students"
        } 
    }
    
}

extension StudentListViewController {
    
    func setUp() {
        newEntryView.isHidden = true
        tableView.rowHeight = 80.0
        plusBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonPressed(_:)))
        saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveNewStudent))
        cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(saveNewStudent))
        navigationItem.rightBarButtonItem = plusBarButton
    }
    
    func toggleEntryView(hidden: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.newEntryView.isHidden = hidden
            DispatchQueue.main.async {
                if hidden {
                    self.newStudentTextField.resignFirstResponder()
                } else {
                    self.newStudentTextField.becomeFirstResponder()
                }
            }
        }) { _ in
            self.newStudentTextField.text = ""
        }
    }
    
    func saveNewStudent() {
        if let newGroupName = newStudentTextField.text, newGroupName.isEmpty == false {
            let newGroup = Group(name: newGroupName)
            core.fire(command: CreateObject(object: newGroup))
        }
        isAdding = false
    }
    
    func updateUI(with theme: Theme) {
        plusBarButton.tintColor = theme.tintColor
        saveBarButton.tintColor = theme.tintColor
        cancelBarButton.tintColor = theme.tintColor
    }
    
}

extension StudentListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentTableViewCell.reuseIdentifier) as! StudentTableViewCell
        cell.update(with: students[indexPath.row], theme: core.state.theme)
        cell.delegate = self
        
        return cell
    }
    
}


extension StudentListViewController: StudentCellDelegate {
    
    func saveStudentName(fromCell cell: StudentTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        core.fire(command: UpdateObject(object: students[indexPath.row]))
    }
    
}


extension StudentListViewController: SegueHandling {

    enum SegueIdentifier: String {
        case showGroupSwitcher
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showGroupSwitcher:
            let groupSwitcher = segue.destination
            groupSwitcher.popoverPresentationController?.delegate = self
            groupSwitcher.popoverPresentationController?.sourceView = navigationController?.navigationBar
            let sourceRect = navBarButton.frame.insetBy(dx: -8.0, dy: -8.0)
            groupSwitcher.popoverPresentationController?.sourceRect = sourceRect
        }
    }
    
}

extension StudentListViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}
