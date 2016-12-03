//
//  StudentTicketsViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/27/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class StudentTicketsViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: BetterSegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    var core = App.core
    var isShowingSteppers = false {
        didSet {
            editButton.tintColor = isShowingSteppers ? core.state.theme.tintColor : .darkGray
            editButton.setTitleTextAttributes([NSFontAttributeName: core.state.theme.fontType.font(withSize: 17)], for: .normal)
        }
    }
    var students = [Student]() {
        didSet {
            tableView.reloadData()
        }
    }
    var currentSortType: SortType = App.core.state.theme.lastFirst ? .last : .first {
        didSet {
            students = currentSortType.sort(students)
        }
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
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        isShowingSteppers = !isShowingSteppers
        tableView.reloadData()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        guard let selectedSortType = SortType(rawValue: Int(sender.index)) else { return }
        currentSortType = selectedSortType
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        resetAllTickets()
    }
    
}


// MARK: - Subscriber

extension StudentTicketsViewController: Subscriber {
    
    func update(with state: AppState) {
        students = currentSortType.sort(state.currentStudents)
        tableView.reloadData()
        updateSegmentedControl(theme: state.theme)
    }
    
}


extension StudentTicketsViewController {
    
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
            core.fire(command: UpdateObject(object: updatedStudent))
        }
    }
    
}


extension StudentTicketsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentTicketTableCell.reuseIdentifier) as! StudentTicketTableCell
        var studentAtRow = students[indexPath.row]
        cell.update(with: studentAtRow, theme: core.state.theme)
        cell.stepperCompletion = { stepValue in
            studentAtRow.tickets = stepValue
            self.core.fire(command: UpdateObject(object: studentAtRow))
        }
        cell.isShowingStepper = isShowingSteppers
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isShowingSteppers == false, let editButton = navigationItem.leftBarButtonItem {
            editButtonPressed(editButton)
        }
    }
    
}

extension StudentTicketsViewController {
    
enum SortType: Int {
    case first
    case last
    case tickets
    
    var buttonTitle: String {
        switch self {
        case .first:
            return "First"
        case .last:
            return "Last"
        case .tickets:
            return "# Tickets"
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
        case .tickets:
            return { students in
                return students.sorted(by: { $0.tickets > $1.tickets })
            }
        }
    }
    static let allValues = [SortType.first, .last, .tickets]
}

func updateSegmentedControl(theme: Theme) {
    segmentedControl.titles = SortType.allValues.map { $0.buttonTitle }
    segmentedControl.backgroundColor = theme.mainColor
    segmentedControl.titleColor = theme.textColor
    segmentedControl.titleFont = theme.fontType.font(withSize: 16)
    segmentedControl.selectedTitleFont = theme.fontType.font(withSize: 18)
    segmentedControl.indicatorViewBackgroundColor = theme.tintColor
    segmentedControl.cornerRadius = 5
}

}