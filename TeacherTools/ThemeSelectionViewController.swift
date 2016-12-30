//
//  ThemeSelectionViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/28/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class ThemeSelectionViewController: UIViewController, AutoStoryboardInitializable {

    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var flowLayout = UICollectionViewFlowLayout()
    fileprivate var dataSource = ThemesCollectionViewDataSource()
    
    var core = App.core
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        core.remove(subscriber: self)
    }
    
}

// MARK: - Subscriber

extension ThemeSelectionViewController: Subscriber {
    
    func update(with state: AppState) {
        
    }
    
}




extension ThemeSelectionViewController {
    
    fileprivate func setUp() {
        let nib = UINib(nibName: String(describing: ThemeCollectionViewCell.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ThemeCollectionViewCell.reuseIdentifier)
        let height = collectionView.bounds.height
        flowLayout.itemSize = CGSize(width: height * 0.75, height: height - 16)
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
        collectionView.dataSource = dataSource
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTheme = dataSource.themes[indexPath.item]
        if selectedTheme.isLocked {
            showProVC()
        } else if selectedTheme.id != core.state.currentUser?.themeID, let currentUser = core.state.currentUser {
            currentUser.themeID = selectedTheme.id
            core.fire(command: UpdateUser(user: currentUser))
            collectionView.reloadData()
        }
    }
    func showProVC() {
        let proVC = ProViewController.initializeFromStoryboard().embededInNavigationController
        present(proVC, animated: true, completion: nil)
    }

}
