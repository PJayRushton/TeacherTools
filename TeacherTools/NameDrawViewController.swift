//
//  NameDrawViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class NameDrawViewController: UIViewController, AutoStoryboardInitializable {
    
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
    
    @IBAction func topViewTapped(_ sender: UITapGestureRecognizer) {
        drawName()
    }
    
}

extension NameDrawViewController {
    
    func drawName() {
        guard allStudents.count > 0 else { currentStudent = nil; return }
        currentStudent = allStudents.removeLast()
    }
    
    func handleNewStudent(_ student: Student?, previousStudent: Student?) {
        if let newStudent = student {
            animateTopLabel() {
                self.topLabel.text = newStudent.displayedName
            }
            addPrevious(student: previousStudent)
        } else {
            topLabel.text = emptyStudentsString
            updateCountLabel()
        }
    }
    
    func animateTopLabel(completion: @escaping () -> Void) {
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
    }
    
    fileprivate func addPrevious(student: Student?) {
        if let previousStudent = student {
            selectedStudents.append(previousStudent)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .top)
            tableView.endUpdates()
        } else if allStudents.isEmpty {
            allStudents = core.state.currentStudents.shuffled()
            selectedStudents.removeAll()
            tableView.reloadData()
            drawName()
        }
        updateCountLabel()
        
    }
    
    fileprivate func updateCountLabel() {
        let drawnNamesCount = currentStudent == nil ? selectedStudents.count : selectedStudents.count + 1
        countLabel.text = "\(drawnNamesCount)/\(core.state.currentStudents.count)"
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
