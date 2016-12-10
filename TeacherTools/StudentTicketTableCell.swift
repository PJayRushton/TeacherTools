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
    @IBOutlet weak var ticketImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var stepper: GMStepper!
    
    var stepperCompletion: ((Int) -> Void)?
    var student: Student?
    var isShowingStepper = false {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.readyOnlyStack.isHidden = self.isShowingStepper
                self.stepper.isHidden = !self.isShowingStepper
                self.stepper.alpha = self.isShowingStepper ? 1 : 0
            }, completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        readyOnlyStack.isHidden = false
        stepper.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        readyOnlyStack.isHidden = isShowingStepper
        stepper.isHidden = !isShowingStepper
    }
    
    func update(with student: Student, theme: Theme) {
        self.student = student
        nameLabel.text = student.displayedName
        stepper.value = Double(student.tickets)
        countLabel.text = "\(student.tickets)"
        
        ticketImageView.tintColor = .ticketRed
        nameLabel.font = theme.font(withSize: 17)
        stepper.labelFont = theme.font(withSize: 20)
        stepper.buttonsFont = theme.font(withSize: 22)
        stepper.labelTextColor = .white
        stepper.labelBackgroundColor = theme.tintColor
    }
    
    @IBAction func stepperValueChanged(_ sender: GMStepper) {
        guard let student = student, Int(sender.value) != student.tickets else { return }
        stepperCompletion?(Int(sender.value))
    }
    
}
