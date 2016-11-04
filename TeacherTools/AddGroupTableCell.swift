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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circleView.layer.cornerRadius = circleView.bounds.height / 2
        circleView.backgroundColor = App.core.state.theme.tintColor
    }

}
