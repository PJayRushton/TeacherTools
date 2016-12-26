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
    
    private let checkImageView = UIImageView(image: UIImage(named: "check"))
    private let selectedColor = App.core.state.theme.textColor.withAlphaComponent(0.2)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundColor = highlighted ? selectedColor : .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        backgroundColor = selected ? selectedColor : .clear
    }
    
    func update(with group: Group, theme: Theme, isSelected: Bool) {
        titleLabel.text = group.name
        subtitleLabel.text = String(format: "%d students", group.studentIds.count)
        accessoryView = isSelected ? checkImageView : nil
        accessoryView?.tintColor = theme.tintColor
        update(with: theme)
    }
    
    func update(with theme: Theme) {
        var size = titleLabel.font.pointSize
        titleLabel.font = theme.font(withSize: size)
        titleLabel.textColor = theme.textColor
        size = subtitleLabel.font.pointSize
        subtitleLabel.font = theme.font(withSize: size)
        subtitleLabel.textColor = theme.textColor
    }
    
}
