//
//  StudentListViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/31/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class StudentListViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navBarButton: NavBarButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newEntryView: UIView!
    @IBOutlet weak var newStudentTextField: UITextField!
    @IBOutlet weak var segmentedControl: BetterSegmentedControl!

    var core = App.core
    var group: Group?
    var students = [Student]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    fileprivate var plusBarButton = UIBarButtonItem()
    fileprivate var pasteBarButton = UIBarButtonItem()
    fileprivate var saveBarButton = UIBarButtonItem()
    fileprivate var cancelBarButton = UIBarButtonItem()
    fileprivate var doneBarButton = UIBarButtonItem()
    fileprivate var editBarButton = UIBarButtonItem()
    
    var currentSortType: SortType = App.core.state.currentUser!.lastFirst ? .last : .first {
        didSet {
            students = currentSortType.sort(students)
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func newStudentTextFieldChanged(_ sender: UITextField) {
        updateRightBarButton()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        guard let selectedSortType = SortType(rawValue: Int(sender.index)) else { return }
        currentSortType = selectedSortType
    }
    
    func editButtonPressed(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        tableView.reloadData()
        navigationItem.leftBarButtonItem = tableView.isEditing ? doneBarButton : editBarButton
    }
    
}


// MARK: - Subscriber

extension StudentListViewController: Subscriber {
    
    func update(with state: AppState) {
        if let group = state.selectedGroup {
            self.group = group
            navBarButton.mainTitle = group.name
        }
        navBarButton.subTitle = "\(state.currentStudents.count) students"
        students = currentSortType.sort(state.currentStudents)
        newStudentTextField.text = ""
        updateUI(with: state.theme)
    }
    
}


// MARK: - FilePrivate

extension StudentListViewController {
    
    func setUp() {
        plusBarButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(startEditing))
        plusBarButton.setTitleTextAttributes([NSFontAttributeName: core.state.theme.font(withSize: core.state.theme.plusButtonSize)], for: .normal)
        pasteBarButton = UIBarButtonItem(image: UIImage(named: "lines"), style: .plain, target: self, action: #selector(pasteButtonPressed))
        saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveNewStudent))
        cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(saveNewStudent))
        editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed(_:)))
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonPressed(_:)))
        navigationItem.setLeftBarButton(editBarButton, animated: true)
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
    
    func pasteButtonPressed() {
        let addStudentsVC = AddStudentsViewController.initializeFromStoryboard()
        navigationController?.pushViewController(addStudentsVC, animated: true)
    }
    
    func saveNewStudent() {
        if newStudentTextField.text!.isEmpty { isAdding = false; return }
        if let newStudentName = newStudentTextField.text, newStudentName.isEmpty == false {
            guard newStudentName.isValidName else {
                core.fire(event: ErrorEvent(error: nil, message: "Unaccepted name format"))
                return
            }
            guard let currentUser = core.state.currentUser else { return }
            let id = FirebaseNetworkAccess.sharedInstance.studentsRef(userId: currentUser.id).childByAutoId()
            let newStudent = Student(id: id.key, name: newStudentName)
            core.fire(command: CreateStudent(student: newStudent))
        } else {
            isAdding = false
        }
    }
    
    func updateUI(with theme: Theme) {
        backgroundImageView.image = theme.mainImage.image
        let borderImage = theme.borderImage.image.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationController?.navigationBar.setBackgroundImage(borderImage, for: .default)
        
        for barButton in [plusBarButton, pasteBarButton, saveBarButton, cancelBarButton, editBarButton] {
            barButton.tintColor = theme.textColor
            barButton.setTitleTextAttributes([NSFontAttributeName: theme.font(withSize: 20)], for: .normal)
        }
        plusBarButton.setTitleTextAttributes([NSFontAttributeName: theme.font(withSize: theme.plusButtonSize)], for: .normal)
        navBarButton.tintColor = theme.textColor
        navBarButton.update(with: theme)
        updateRightBarButton()
        updateSegmentedControl(theme: theme)
        newStudentTextField.font = theme.font(withSize: newStudentTextField.font?.pointSize ?? 20)
        newStudentTextField.textColor = theme.textColor
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


// MARK: - TableView

extension StudentListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentTableViewCell.reuseIdentifier) as! StudentTableViewCell
        cell.update(with: students[indexPath.row], theme: core.state.theme, isEditing: tableView.isEditing)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let studentToX = students[indexPath.row]
            if let cell = tableView.cellForRow(at: indexPath) as? StudentTableViewCell {
                cell.textField.resignFirstResponder()
            }
            core.fire(command: DeleteStudent(student: studentToX))
        }
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
        segmentedControl.titles = SortType.allValues.map { $0.buttonTitle }
        segmentedControl.backgroundColor = .clear
        segmentedControl.titleColor = theme.textColor
        segmentedControl.titleFont = theme.font(withSize: 16)
        segmentedControl.selectedTitleFont = theme.font(withSize: 18)
        segmentedControl.indicatorViewBackgroundColor = theme.tintColor
        segmentedControl.cornerRadius = 5
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
            let groupSwitcher = segue.destination as! GroupListViewController
            groupSwitcher.popoverPresentationController?.delegate = self
            groupSwitcher.popoverPresentationController?.sourceView = navigationController?.navigationBar
            let sourceRect = navBarButton.frame.insetBy(dx: -8.0, dy: -8.0)
            groupSwitcher.popoverPresentationController?.sourceRect = sourceRect
            groupSwitcher.proCompletion = {
                let proViewController = ProViewController.initializeFromStoryboard().embededInNavigationController
                self.present(proViewController, animated: true, completion: nil)
            }
            animateArrow(up: true)
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
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        animateArrow(up: false)
        return true
    }
    
}
