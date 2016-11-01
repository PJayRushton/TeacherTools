//
//  StudentTableViewCell.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/31/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

protocol StudentCellDelegate {
    func saveStudentName(fromCell cell: StudentTableViewCell)
}

class StudentTableViewCell: UITableViewCell, AutoReuseIdentifiable {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    var delegate: StudentCellDelegate?
    
    func update(with student: Student, theme: Theme) {
        textField.text = student.displayedName
    }
    
    func update(with theme: Theme) {
        doneButton.tintColor = theme.tintColor
        textField.textColor = theme.textColor
        textField.font = theme.fontType.font(withSize: textField.font!.pointSize)
    }
    
    func startEditing() {
        textField.becomeFirstResponder()
        toggleDoneButton(show: true)
    }

    @IBAction func doneButtonPressed(_ sender: UIButton) {
        textField.resignFirstResponder()
        toggleDoneButton(show: false)
    }
    
}


extension StudentTableViewCell: UITextFieldDelegate {
    
    func toggleDoneButton(show: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: { 
            self.doneButton.isHidden = !show
        }, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.saveStudentName(fromCell: self)
    }
    
}
