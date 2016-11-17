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
    fileprivate var allStudents = [Student]()
    fileprivate var selectedStudents = [Student]()
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
        if let currentStudent = currentStudent {
            animateTopLabel() {
                self.updateUI(withNewStudent: student, previousStudent: previousStudent)
                updateCountLabel()
            }
        } else {
            topLabel.text = "Press me to draw a new name"
            updateCountLabel()
        }
    }
        
    func animateTopLabel(completion: () -> Void) {
        
    }
    
    func updateUI(withNewStudent new: Student?, previousStudent: Student?) {
        
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
