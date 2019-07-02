//
//  StudentListViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/31/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet var noGroupsView: UIView!
    
    @IBOutlet var emptyGroupView: UIView!
    @IBOutlet var emptyStateImages: [UIImageView]!
    @IBOutlet var emptyStateLabels: [UILabel]!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navBarButton: NavBarButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableSortHeader: UIView!
    @IBOutlet weak var newEntryView: UIView!
    @IBOutlet weak var newStudentTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var core = App.core
    var group: Group?
    var students = [Student]()
    var absentStudents = [Student]()
    
    fileprivate var plusBarButton = UIBarButtonItem()
    fileprivate var pasteBarButton = UIBarButtonItem()
    fileprivate var saveBarButton = UIBarButtonItem()
    fileprivate var cancelBarButton = UIBarButtonItem()
    fileprivate var doneBarButton = UIBarButtonItem()
    fileprivate var editBarButton = UIBarButtonItem()
    
    var currentSortType: SortType = App.core.state.currentUser?.lastFirst == true ? .last : .first {
        didSet {
            students = currentSortType.sort(students)
            tableView.reloadData()
            isAdding = false
        }
    }
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
        
        if !navBarButton.isPointingDown {
            animateArrow(up: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
    }
    
    @IBAction func newStudentTextFieldChanged(_ sender: UITextField) {
        updateRightBarButton()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let selectedSortType = SortType(rawValue: sender.selectedSegmentIndex) else { return }
        currentSortType = selectedSortType
    }
    
    @IBAction func pasteViewTapped(_ sender: UITapGestureRecognizer) {
        pasteButtonPressed()
    }
    
    @IBAction func addViewTapped(_ sender: UITapGestureRecognizer) {
        startEditing()
    }
    
    @objc func editButtonPressed(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        tableView.reloadData()
        navigationItem.leftBarButtonItem = tableView.isEditing ? doneBarButton : editBarButton
    }
    
}


// MARK: - Subscriber

extension StudentListViewController: Subscriber {
    
    func update(with state: AppState) {
        newStudentTextField.text = ""
        updateUI(with: state.theme)
        tableView.tableHeaderView = state.selectedGroup == nil ? nil : tableSortHeader
        
        tableView.backgroundView = nil
        if state.groups.isEmpty {
            tableView.backgroundView = noGroupsView
        } else if let selectedGroup = state.selectedGroup, selectedGroup.studentIds.isEmpty {
            tableView.backgroundView = emptyGroupView
        }

        navBarButton.update(with: state.selectedGroup)
        guard let group = state.selectedGroup else { return }
        self.group = group
        absentStudents = state.absentStudents
        students = currentSortType.sort(state.currentStudents)
        
        let shouldShowEmptyView = core.state.groupsAreLoaded && students.isEmpty
        tableView.backgroundView = shouldShowEmptyView ? emptyGroupView : nil

        tableView.reloadData()
    }
    
}


// MARK: - FilePrivate

extension StudentListViewController {
    
    func setUp() {
        plusBarButton = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(startEditing))
        plusBarButton.setTitleTextAttributes([NSAttributedString.Key.font: core.state.theme.font(withSize: core.state.theme.plusButtonSize)], for: .normal)
        pasteBarButton = UIBarButtonItem(image: UIImage(named: "lines"), style: .plain, target: self, action: #selector(pasteButtonPressed))
        saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveNewStudent))
        cancelBarButton = UIBarButtonItem(image: UIImage(named: "x"), style: .plain, target: self, action: #selector(saveNewStudent))
        editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed(_:)))
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonPressed(_:)))
        navigationItem.setLeftBarButton(editBarButton, animated: true)
        navigationItem.setRightBarButton(plusBarButton, animated: true)
        newEntryView.isHidden = true
        
        let nib = UINib(nibName: String(describing: StudentTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: StudentTableViewCell.reuseIdentifier)
        tableView.rowHeight = Platform.isPad ? 60 : 45.0
        resetAllCells()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow(notification: NSNotification) {
        var keyboardHeight: CGFloat = 216
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        tableView.contentInset = insets
    }
    
    @objc func handleKeyboardDidHide() {
        tableView.contentInset = UIEdgeInsets.zero
    }
    
    func toggleEntryView(hidden: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.newEntryView.isHidden = hidden
            self.newEntryView.alpha = hidden ? 0 : 1
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
    
    @objc func pasteButtonPressed() {
        let addStudentsVC = AddStudentsViewController.initializeFromStoryboard()
        navigationController?.pushViewController(addStudentsVC, animated: true)
    }
    
    @objc func saveNewStudent() {
        if newStudentTextField.text!.isEmpty { isAdding = false; return }
        if let newStudentName = newStudentTextField.text, newStudentName.isEmpty == false {
            guard newStudentName.isValidName else {
                core.fire(event: ErrorEvent(error: nil, message: "Unaccepted name format"))
                return
            }
            let newStudent = Student(name: newStudentName)
            core.fire(command: CreateStudent(student: newStudent))
        } else {
            isAdding = false
        }
    }
    
    func updateUI(with theme: Theme) {
        for label in emptyStateLabels {
            label.textColor = theme.textColor
            label.font = theme.font(withSize: 18)
        }
        for image in emptyStateImages {
            image.tintColor = theme.tintColor
        }
        backgroundImageView.image = theme.mainImage.image
        let borderImage = theme.borderImage.image.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationController?.navigationBar.setBackgroundImage(borderImage, for: .default)
        
        for barButton in [plusBarButton, pasteBarButton, saveBarButton, cancelBarButton, editBarButton] {
            barButton.tintColor = theme.textColor
            barButton.setTitleTextAttributes([NSAttributedString.Key.font: theme.font(withSize: 20)], for: .normal)
        }
        plusBarButton.setTitleTextAttributes([NSAttributedString.Key.font: theme.font(withSize: theme.plusButtonSize)], for: .normal)
        navBarButton.tintColor = theme.textColor
        navBarButton.update(with: theme)
        updateRightBarButton()
        updateSegmentedControl(theme: theme)
        newStudentTextField.font = theme.font(withSize: 20)
        newStudentTextField.textColor = theme.textColor
    }
    
    @objc func startEditing() {
        isAdding = true
    }
    
    func resetAllCells() {
        guard let visibleStudentCells = tableView.visibleCells as? [StudentTableViewCell] else { return }
        for cell in visibleStudentCells {
            cell.isEditing = false
        }
    }
    
}


// MARK: - TableView

extension StudentListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return absentStudents.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? students.count : absentStudents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentTableViewCell.reuseIdentifier) as! StudentTableViewCell
        let student = indexPath.section == 1 ? absentStudents[indexPath.row] : students[indexPath.row]
        cell.update(with: student, theme: core.state.theme, isEditing: tableView.isEditing)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == false {
            editButtonPressed(editBarButton)
            guard let cell = tableView.cellForRow(at: indexPath) as? StudentTableViewCell else { return }
            cell.textField.becomeFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Absent" : nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexPath in
            let studentToX = indexPath.section == 0 ? self.students[indexPath.row] : self.absentStudents[indexPath.row]
            self.core.fire(command: DeleteStudent(student: studentToX))
        })
        
        guard let currentUser = core.state.currentUser else { return [deleteAction] }
        
        let absentAction = UITableViewRowAction(style: .normal, title: "Absent", handler: { action, indexPath in
            if currentUser.isPro {
                self.core.fire(event: MarkStudentAbsent(student: self.students[indexPath.row]))
            } else {
                self.goPro()
            }
        })
        let presentAction = UITableViewRowAction(style: .normal, title: "Present", handler: { action, indexPath in
            if currentUser.isPro {
                self.core.fire(event: MarkStudentPresent(student: self.absentStudents[indexPath.row]))
            } else {
                self.goPro()
            }
        })
        switch indexPath.section {
        case 0:
            return [deleteAction, absentAction]
        case 1:
            return [deleteAction, presentAction]
        default:
            return [deleteAction]
        }
    }

    func goPro() {
        let proVC = ProViewController.initializeFromStoryboard().embededInNavigationController
        proVC.modalPresentationStyle = .popover
        proVC.popoverPresentationController?.sourceView = navBarButton
        proVC.popoverPresentationController?.sourceRect = navBarButton.bounds
        present(proVC, animated: true, completion: nil)
    }
    
}


// MARK: - TextField Delegate

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
            navigationItem.setRightBarButtonItems([plusBarButton, pasteBarButton], animated: true)
        }
    }
    
}


// MARK: - SegmentedControl

extension StudentListViewController {
 
    enum SortType: Int {
        case first
        case last
        case random
        
        var buttonTitle: String {
            switch self {
            case .first:
                return "First"
            case .last:
                return "Last"
            case .random:
                return "Random"
            }
        }
        
        var sort: (([Student]) -> [Student]) {
            switch self {
            case .first:
                return { students in
                    return students.sorted(by: { $0.firstName < $1.firstName })
                }
            case .last:
                return { students in
                    return students.sorted(by: { ($0.lastName ?? $0.firstName) < ($1.lastName ?? $1.firstName) })
                }
            case .random:
                return { students in
                    return students.shuffled()
                }
            }
        }
        static let allValues = [SortType.first, .last, .random]
    }
    
    func updateSegmentedControl(theme: Theme) {
        SortType.allValues.forEach { segmentedControl.setTitle($0.buttonTitle, forSegmentAt: $0.rawValue) }
        segmentedControl.tintColor = theme.tintColor
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: theme.font(withSize: 17)], for: .normal)
    }
    
}


extension StudentListViewController: StudentCellDelegate {
    
    func saveStudentName(_ name: FullName, forCell cell: StudentTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var updatedStudent = students[indexPath.row]
        updatedStudent.firstName = name.first
        updatedStudent.lastName = name.last
        core.fire(command: CreateStudent(student: updatedStudent))
    }
    
}


extension StudentListViewController: SegueHandling {

    enum SegueIdentifier: String {
        case showGroupSwitcher
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .showGroupSwitcher:
            guard let groupSwitcherNav = segue.destination as? UINavigationController, let groupSwitcher = groupSwitcherNav.viewControllers.first as? GroupListViewController else { return }
            groupSwitcher.proCompletion = {
                let proViewController = ProViewController.initializeFromStoryboard().embededInNavigationController
                self.present(proViewController, animated: true, completion: nil)
            }
            groupSwitcher.arrowCompletion = { up in
                self.animateArrow(up: up)
            }
        }
    }
    
    fileprivate func animateArrow(up: Bool = true) {
        UIView.animate(withDuration: 0.25) {
            let transform = up ? CGAffineTransform(rotationAngle: -CGFloat.pi) : CGAffineTransform(rotationAngle: CGFloat.pi * 2)
            self.navBarButton.icon.transform = transform
        }
    }
    
}

extension StudentListViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}
