//
//  StudentListViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/31/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController, AutoStoryboardInitializable {

    @IBOutlet weak var tableView: UITableView!
    
    var core = App.core
    var group: Group?
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
    
}


// MARK: - Subscriber

extension StudentListViewController: Subscriber {
    
    func update(with state: AppState) {
        if let group = state.selectedGroup {
            self.group = group
            title = group.name
        } else {
            core.fire(event: ErrorEvent(error: nil, message: "Error retreiving students"))
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
    
}


extension StudentListViewController: StudentCellDelegate {
    
    func saveStudentName(fromCell cell: StudentTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        core.fire(command: UpdateObject(object: students[indexPath.row]))
    }
    
}
