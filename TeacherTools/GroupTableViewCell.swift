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
        subtitleLabel.text = String(format: "%d students", group.students.count)
        update(with: theme)
    }
    
    func update(with theme: Theme) {
        var size = titleLabel.font.pointSize
        titleLabel.font = theme.fontType.font(withSize: size)
        titleLabel.textColor = theme.textColor
        size = subtitleLabel.font.pointSize
        subtitleLabel.font = theme.fontType.font(withSize: size)
        subtitleLabel.textColor = theme.textColor
    }
    
}
