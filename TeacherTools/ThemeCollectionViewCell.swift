//
//  ThemeCollectionViewCell.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/3/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class ThemeCollectionViewCell: UICollectionViewCell, AutoReuseIdentifiable {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet var otherLabels: [UILabel]!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var lockImageView: UIImageView!
    
    func update(with theme: Theme, isLocked: Bool = true) {
        mainView.backgroundColor = theme.mainColor
        firstNameLabel.backgroundColor = theme.tintColor
        firstNameLabel.font = theme.fontType.font(withSize: 13)
        for label in otherLabels {
            label.textColor = theme.textColor
            label.font = theme.fontType.font(withSize: 11)
        }
        topLabel.font = theme.fontType.font(withSize: 15)
        grayView.backgroundColor = isLocked ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.clear
        lockImageView.isHidden = !isLocked
    }
    
}
