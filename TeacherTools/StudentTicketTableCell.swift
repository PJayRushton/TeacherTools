//
//  StudentTicketTableCell.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/27/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class StudentTicketTableCell: UITableViewCell, AutoReuseIdentifiable {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var readyOnlyStack: UIStackView!
    @IBOutlet weak var ticketImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var stepperCompletion: ((Int) -> Void)?
    var student: Student?
    var isShowingStepper = false {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
//                self.readyOnlyStack.isHidden = self.isShowingStepper
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
        countLabel.text = String(student.tickets)
        updateUI(with: theme)
    }
    
    fileprivate func updateUI(with theme: Theme) {
        nameLabel.textColor = theme.textColor
        nameLabel.font = theme.font(withSize: 20)
        ticketImageView.tintColor = stepper.value == 1 ? UIColor.ticketRed.withAlphaComponent(0.6) : .ticketRed
        countLabel.textColor = theme.textColor
        countLabel.font = theme.font(withSize: 17)
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        guard let student = student, case let newValue = Int(sender.value), newValue != student.tickets else { return }
        countLabel.text = String(newValue)
        stepperCompletion?(newValue)
    }
    
}
