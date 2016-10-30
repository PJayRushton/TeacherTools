//
//  GroupTableViewCell.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell, AutoReuseIdentifiable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func update(with group: Group, theme: Theme) {
        titleLabel.text = group.name
    }
    
}
