//
//  GroupToolCollectionViewCell.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class GroupToolCollectionViewCell: UICollectionViewCell, AutoReuseIdentifiable {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    func update(with tool: Tool, theme: Theme) {
        imageView.image = tool.image
        textLabel.text = tool.title
        update(with: theme)
    }
    
    func update(with theme: Theme) {
        imageView.tintColor = theme.tintColor
        let fontSize = textLabel.font.pointSize
        textLabel.font = theme.font(withSize: fontSize)
    }
    
}
