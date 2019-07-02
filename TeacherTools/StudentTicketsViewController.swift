//
//  StudentTicketsViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/27/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class StudentTicketsViewController: UIViewController, AutoStoryboardInitializable {
    
    // MARK: - Outlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var resetButton: UIBarButtonItem!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    
    var core = App.core
    private var isShowingSteppers = false
    private var students = [Student]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var currentSortType: SortType = App.core.state.currentUser!.lastFirst ? .last : .first
    
    
    // MARK: - Lifecycle
    
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
    
    
    // MARK: - Actions
    
    @IBAction func doneButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPressed() {
        showResetConfirmationAlert()
    }
    
    @IBAction func savePressed() {
        
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let selectedSortType = SortType(rawValue: sender.selectedSegmentIndex) else { return }
        currentSortType = selectedSortType
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        resetAllTickets()
    }
    
}


// MARK: - Subscriber

extension StudentTicketsViewController: Subscriber {
    
    func update(with state: AppState) {
        students = state.currentStudents.sorted(by: currentSortType)
        tableView.reloadData()
        updateUI(with: state.theme)
    }
    
}


// MARK: - Private

private extension StudentTicketsViewController {
    
    func updateUI(with theme: Theme) {
        backgroundImageView.image = theme.mainImage.image
        let borderImage = theme.borderImage.image.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationController?.navigationBar.setBackgroundImage(borderImage, for: .default)
        saveButton.tintColor = theme.textColor
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: core.state.theme.font(withSize: 17)], for: .normal)
        dismissButton.tintColor = theme.textColor
        updateSegmentedControl(with: theme)
        resetButton.titleLabel?.font = theme.font(withSize: 17)
    }
    
    func updateSegmentedControl(with theme: Theme) {
        SortType.allCases.forEach { segmentedControl.setTitle($0.buttonTitle, forSegmentAt: $0.rawValue) }
        segmentedControl.tintColor = theme.tintColor
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: theme.font(withSize: 17)], for: .normal)
    }

    func showResetConfirmationAlert() {
        let alert = UIAlertController(title: "This will reset all ticket amounts back to 1", message: "Is this what you want to do?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
            self.resetAllTickets()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func resetAllTickets(to newTicketValue: Int = 1) {
        for student in students {
            guard student.tickets != newTicketValue else { continue }
            var updatedStudent = student
            updatedStudent.tickets = newTicketValue
            core.fire(command: updatedStudent())
        }
    }
    
}


// MARK: - TableView

extension StudentTicketsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func student(at index: IndexPath) -> Student {
        return dirtyStudents.sorted(by: currentSortType)[index.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentTicketTableCell.reuseIdentifier) as! StudentTicketTableCell
        var updatedStudent = student(at: indexPath)
        cell.update(with: updatedStudent, theme: core.state.theme)
        cell.stepperCompletion = { stepValue in
            updatedStudent.tickets = stepValue
            self.dirtyStudents.update(with: updatedStudent)
        }
        cell.isShowingStepper = isShowingSteppers
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        isShowingSteppers = true
        tableView.reloadData()
    }
    
}
