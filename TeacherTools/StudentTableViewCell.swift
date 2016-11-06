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
    var student: Student?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doneButton.isHidden = true
        textField.layer.cornerRadius = 5.0
    }
    
    override var isEditing: Bool {
        didSet {
            isSelected = isEditing
            textField.borderStyle = isEditing ? .line : .none
            if isEditing {
                textField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            toggleDoneButton(show: isEditing)
        }
    }
    
    func update(with student: Student, theme: Theme) {
        self.student = student
        textField.text = student.displayedName
    }
    
    func update(with theme: Theme) {
        doneButton.tintColor = theme.tintColor
        textField.textColor = theme.textColor
        textField.font = theme.fontType.font(withSize: textField.font!.pointSize)
    }

    @IBAction func doneButtonPressed(_ sender: UIButton) {
        saveNewName()
    }
    
}


extension StudentTableViewCell {
    
    func saveNewName() {
        if let name = textField.text, name.isEmpty == false && name != student?.displayedName {
            delegate?.saveStudentName(fromCell: self)
        }
        isEditing = false
        toggleDoneButton(show: false)
    }
    
}


extension StudentTableViewCell: UITextFieldDelegate {
    
    func toggleDoneButton(show: Bool) {
        self.doneButton.isHidden = !show
//        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: { 
//            self.doneButton.isHidden = !show
//        }, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.saveStudentName(fromCell: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveNewName()
        return true
    }
    
}
