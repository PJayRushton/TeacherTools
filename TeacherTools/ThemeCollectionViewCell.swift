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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 5
    }
    
    override var isSelected: Bool {
        didSet {

        }
    }

    func update(with theme: Theme, isLocked: Bool = true, isSelected: Bool) {
        mainView.layer.borderColor = isSelected ? UIColor.appleBlue.cgColor : UIColor.darkGray.cgColor
        mainView.layer.borderWidth = isSelected ? 4 : 1
        mainImageView.image = theme.mainImage.image
        topImageView.image = theme.borderImage.image
        topLabel.text = theme.name
        firstNameLabel.backgroundColor = theme.tintColor
        firstNameLabel.font = theme.font(withSize: 13)
        for label in otherLabels {
            label.textColor = theme.textColor
            label.font = theme.font(withSize: 11)
        }
        topLabel.font = theme.font(withSize: 15)
        grayView.backgroundColor = isLocked ? UIColor.darkGray.withAlphaComponent(0.6) : UIColor.clear
        lockImageView.isHidden = !isLocked
    }
    
}
