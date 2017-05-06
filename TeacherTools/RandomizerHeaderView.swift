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
    var completion: (() -> Void)?
    
    func update(with title: String, theme: Theme) {
        textLabel.text = title
        textLabel.backgroundColor = theme.tintColor
        textLabel.textColor = .white
        textLabel.font = theme.font(withSize: 18)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        completion?()
    }
    
}
