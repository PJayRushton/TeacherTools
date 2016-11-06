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
        setUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func newStudentTextFieldChanged(_ sender: UITextField) {
        updateRightBarButton()
    }
    
}


// MARK: - Subscriber

extension StudentListViewController: Subscriber {
    
    func update(with state: AppState) {
        if let group = state.selectedGroup {
            self.group = group
            navBarButton.mainTitle = group.name
            navBarButton.subTitle = "\(group.studentIds.count) students"
            students = state.currentStudents
            newStudentTextField.text = ""
            
        }
        updateUI(with: state.theme)
        tableView.reloadData()
    }
    
}

extension StudentListViewController {
    
    func setUp() {
        plusBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(startEditing))
        saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveNewStudent))
        cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(saveNewStudent))
        navigationItem.setRightBarButton(plusBarButton, animated: true)
        newEntryView.isHidden = true
        
        let nib = UINib(nibName: String(describing: StudentTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: StudentTableViewCell.reuseIdentifier)
        tableView.rowHeight = 50.0
        resetAllCells()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func handleKeyboardDidShow(notification: NSNotification) {
        var keyboardHeight: CGFloat = 216
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        tableView.contentInset = insets
    }
    
    func handleKeyboardDidHide() {
        tableView.contentInset = UIEdgeInsets.zero
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
            self.updateRightBarButton()
        }
    }
    
    func saveNewStudent() {
        if let newStudentName = newStudentTextField.text, newStudentName.isEmpty == false {
            guard let currentUser = core.state.currentUser else { return }
            let id = FirebaseNetworkAccess.sharedInstance.studentsRef(userId: currentUser.id).childByAutoId()
            let newStudent = Student(id: id.key, firstName: newStudentName)
            core.fire(command: CreateStudent(student: newStudent))
        } else {
            isAdding = false
        }
    }
    
    func updateUI(with theme: Theme) {
        plusBarButton.tintColor = theme.tintColor
        saveBarButton.tintColor = theme.tintColor
        cancelBarButton.tintColor = theme.tintColor
        updateRightBarButton()
    }
    
    func startEditing() {
        isAdding = true
    }
    
    func resetAllCells() {
        guard let visibleStudentCells = tableView.visibleCells as? [StudentTableViewCell] else { return }
        for cell in visibleStudentCells {
            cell.isEditing = false
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resetAllCells()
        guard let cell = tableView.cellForRow(at: indexPath) as? StudentTableViewCell else { return }
        cell.isEditing = !cell.isEditing
    }
    
}

extension StudentListViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateRightBarButton()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateRightBarButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveNewStudent()
        return true
    }
    
    func updateRightBarButton() {
        if isAdding {
            if let name = newStudentTextField.text, name.isEmpty == false {
                navigationItem.setRightBarButton(saveBarButton, animated: false)
            } else {
                navigationItem.setRightBarButton(cancelBarButton, animated: false)
            }
        } else {
            navigationItem.setRightBarButton(plusBarButton, animated: false)
        }
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
