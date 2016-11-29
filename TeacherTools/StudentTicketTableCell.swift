//
//  StudentTicketTableCell.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/27/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit
import GMStepper

class StudentTicketTableCell: UITableViewCell, AutoReuseIdentifiable {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var readyOnlyStack: UIStackView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var stepper: GMStepper!
    
    var stepperCompletion: ((Int) -> Void)?
    
    var isShowingStepper = false {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.readyOnlyStack.isHidden = self.isShowingStepper
                self.stepper.isHidden = !self.isShowingStepper
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        readyOnlyStack.isHidden = false
        stepper.isHidden = true
    }
    
    func update(with student: Student, theme: Theme) {
        nameLabel.text = student.displayedName
        stepper.value = Double(student.tickets)
        countLabel.text = "\(student.tickets)"
        
        nameLabel.font = theme.fontType.font(withSize: 17)
        stepper.labelFont = theme.fontType.font(withSize: 13)
        stepper.buttonsFont = theme.fontType.font(withSize: 13)
        stepper.labelTextColor = .white
        stepper.labelBackgroundColor = theme.tintColor
    }
    
    @IBAction func stepperValueChanged(_ sender: GMStepper) {
        stepperCompletion?(Int(sender.value))
    }
    
}
