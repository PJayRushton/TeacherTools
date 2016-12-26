//
//  StudentTableViewCell.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/31/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

protocol StudentCellDelegate {
    func saveStudentName(_ name: FullName, forCell cell: StudentTableViewCell)
}

class StudentTableViewCell: UITableViewCell, AutoReuseIdentifiable {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var delegate: StudentCellDelegate?
    var student: Student?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        saveButton.isHidden = true
        textField.layer.cornerRadius = 5.0
        backgroundColor = .clear
    }
    
    func update(with student: Student, theme: Theme, isEditing: Bool) {
        self.student = student
        textField.text = student.displayedName
        textField.isUserInteractionEnabled = isEditing
        update(with: theme)
    }
    
    fileprivate func update(with theme: Theme) {
        saveButton.tintColor = theme.tintColor
        saveButton.titleLabel?.font = theme.font(withSize: 17)
        textField.textColor = theme.textColor
        textField.font = theme.font(withSize: textField.font!.pointSize)
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveNewName()
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        if let text = sender.text, text.isValidName {
            toggleSaveButton(show: true)
        } else {
            toggleSaveButton(show: false)
        }
    }
    
}


extension StudentTableViewCell {
    
    func saveNewName() {
        if let text = textField.text, text.isValidName {
            delegate?.saveStudentName(text.parsed(), forCell: self)
        }
        toggleSaveButton(show: false)
    }
    
}


extension StudentTableViewCell: UITextFieldDelegate {
    
    func toggleSaveButton(show: Bool) {
//        self.saveButton.isHidden = !show
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.saveButton.isHidden = !show
        }, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveNewName()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveNewName()
        return true
    }
    
}
