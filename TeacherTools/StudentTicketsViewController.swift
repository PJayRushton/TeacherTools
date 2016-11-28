//
//  StudentTicketsViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/27/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class StudentTicketsViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var tableView: UITableView!

    var core = App.core
    var students = [Student]()
    
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
    
    @IBAction func xButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        showResetConfirmationAlert()
    }
    
    
}


// MARK: - Subscriber

extension StudentTicketsViewController: Subscriber {
    
    func update(with state: AppState) {
        students = state.currentStudents
        tableView.reloadData()
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
        cell.isEditing = tableView.isEditing
        
        return cell
    }
    
}
