//
//  RandomizerCollectionViewCell.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/6/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class RandomizerCollectionViewCell: UICollectionViewCell, AutoReuseIdentifiable {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderView.layer.cornerRadius = self.bounds.height * 0.25
        borderView.layer.borderWidth = 1
    }
    
    func update(with student: Student, theme: Theme) {
        textLabel.text = student.displayedName
        borderView.layer.borderColor = theme.tintColor.cgColor
        
        textLabel.font = theme.font(withSize: textLabel.font.pointSize)
    }
    
}
