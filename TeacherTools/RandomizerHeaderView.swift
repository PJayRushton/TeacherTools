//
//  RandomizerHeaderView.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/6/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class RandomizerHeaderView: UICollectionReusableView, AutoReuseIdentifiable {
        
    @IBOutlet weak var textLabel: UILabel!
    
    func update(with title: String, theme: Theme) {
        textLabel.text = title
        textLabel.textColor = theme.textColor
    }
    
}
