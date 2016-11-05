 //
//  AddGroupTableCell.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/4/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class AddGroupTableCell: UITableViewCell, AutoReuseIdentifiable {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var plusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleView.layer.cornerRadius = circleView.frame.width / 2
        circleView.layer.borderWidth = 1
        let themeTintColor = App.core.state.theme.tintColor
        circleView.layer.borderColor = themeTintColor.cgColor
        plusLabel.textColor = themeTintColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.layer.cornerRadius = circleView.frame.width / 2
    }
    
}
