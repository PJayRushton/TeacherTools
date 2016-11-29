//
//  NameDrawViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class NameDrawViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var ticketsButton: UIBarButtonItem!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var drawNameGesture: UITapGestureRecognizer!
    
    fileprivate let cellReuseIdentifier = "NameDrawCell"
    fileprivate let emptyStudentsString = "Tap here to \ndraw a name!"
    fileprivate var allStudents = [Student]()
    fileprivate var selectedStudents = [Student]()
    fileprivate var animator: UIViewPropertyAnimator!
    fileprivate var currentStudent: Student? {
        didSet {
            handleNewStudent(currentStudent, previousStudent: oldValue)
            updateCountLabel()
        }
    }
    
    var core = App.core
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allStudents = core.state.currentStudents.shuffled()
        currentStudent = nil
        tableView.rowHeight = 38
        animator = UIViewPropertyAnimator(duration: 1.5, curve: .easeInOut)
        updateCountLabel()
    }
    
    @IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {
        resetNames()
    }
    
    @IBAction func topViewTapped(_ sender: UITapGestureRecognizer) {
        drawName()
    }
    
    @IBAction func ticketsButtonPressed(_ sender: UIBarButtonItem) {
        let studentTicketsVC = StudentTicketsViewController.initializeFromStoryboard().embededInNavigationController
        present(studentTicketsVC, animated: true, completion: nil)
    }
    
}

extension NameDrawViewController {
    
    func drawName() {
        guard allStudents.count > 0 else { currentStudent = nil; return }
        currentStudent = allStudents.removeLast()
    }
    
    func handleNewStudent(_ student: Student?, previousStudent: Student?) {
        if let newStudent = student {
            changeTopLabel(animated: true) {
                self.topLabel.text = newStudent.displayedName
            }
        } else {
            let isStart = currentStudent == nil && selectedStudents.isEmpty
            topLabel.text = isStart ? emptyStudentsString : allDrawnString()
        }
        addPrevious(student: previousStudent)
    }
    
    func changeTopLabel(animated: Bool = true, completion: @escaping () -> Void) {
        if animated {
            drawNameGesture.isEnabled = false
            topLabel.text = "???"
            animator.addAnimations {
                self.topLabel.rotate()
                self.topLabel.transform = CGAffineTransform(scaleX: 5, y: 5)
                self.topLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            animator.startAnimation()
            animator.addCompletion { position in
                self.drawNameGesture.isEnabled = true
                completion()
            }
        } else {
            completion()
        }
    }
    
    fileprivate func addPrevious(student: Student?) {
        if let previousStudent = student {
            selectedStudents.append(previousStudent)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .top)
            tableView.endUpdates()
        } else if allStudents.isEmpty {
            resetNames()
        }
    }
    
    fileprivate func updateCountLabel() {
        let drawnNamesCount = currentStudent == nil ? selectedStudents.count : selectedStudents.count + 1
        countLabel.text = "\(drawnNamesCount)/\(core.state.currentStudents.count)"
    }
    
    fileprivate func resetNames() {
        if currentStudent != nil {
            currentStudent = nil
        }
        allStudents = core.state.currentStudents.shuffled()
        selectedStudents.removeAll()
        tableView.reloadData()
        updateCountLabel()
        topLabel.text = emptyStudentsString
    }
    
    fileprivate func allDrawnString() -> String {
        let strings = ["That's all she wrote", "You've drawn them all!", "You're all winners!", "Gold stars all around!", "Way to go!", "Everyone's a winner!", "Well that was fun!", "Let's do this again sometime"]
        return strings.randomElement()!
    }
    
}

extension NameDrawViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedStudents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let studentAtRow = selectedStudents.reversed()[indexPath.row]
        cell.textLabel?.text = studentAtRow.displayedName
        
        return cell
    }
    
}
