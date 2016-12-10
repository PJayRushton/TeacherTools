//
//  ThemesCollectionViewDataSource.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/10/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class ThemesCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var themes = [Theme]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThemeCollectionViewCell.reuseIdentifier, for: indexPath) as! ThemeCollectionViewCell
        let theme = themes[indexPath.row]
        cell.update(with: theme, isLocked: theme.isLocked)
        
        return cell
    }
    
}
