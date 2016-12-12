 //
//  AddGroupTableCell.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/4/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class AddGroupTableCell: UITableViewCell, AutoReuseIdentifiable {

    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var addClassLabel: UILabel!
    
    func update(with theme: Theme) {
        plusLabel.textColor = theme.tintColor
        plusLabel.font = theme.font(withSize: 40)
        addClassLabel.textColor = theme.textColor
        addClassLabel.font = theme.font(withSize: 22)
    }
    
}
