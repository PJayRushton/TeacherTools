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
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet var otherLabels: [UILabel]!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 5
        mainView.layer.borderColor = UIColor.darkGray.cgColor
        mainView.layer.borderWidth = 1
    }
    
    func update(with theme: Theme, isLocked: Bool = true, isSelected: Bool) {
        nameLabel.text = theme.name
        checkImageView.isHidden = !isSelected
        mainImageView.image = theme.mainImage.image
        topImageView.image = theme.borderImage.image
        firstNameLabel.backgroundColor = theme.tintColor
        firstNameLabel.font = theme.font(withSize: 13)
        for label in otherLabels {
            label.textColor = theme.textColor
            label.font = theme.font(withSize: 11)
        }
        topLabel.font = theme.font(withSize: 15)
        grayView.backgroundColor = isLocked ? UIColor.lightGray.withAlphaComponent(0.3) : UIColor.clear
        lockImageView.isHidden = !isLocked
    }
    
}
