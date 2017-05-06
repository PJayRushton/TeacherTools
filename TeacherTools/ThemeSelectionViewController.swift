//
//  ThemeSelectionViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/28/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class ThemeSelectionViewController: UIViewController, AutoStoryboardInitializable {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var flowLayout = UICollectionViewFlowLayout()
    fileprivate var dataSource = ThemesCollectionViewDataSource()
    
    var core = App.core
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
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
        dataSource.themes = state.allThemes.sorted(by: { first, second -> Bool in
            return first.isDefault
        })
        collectionView.reloadData()
        updateUI(with: state.theme)
    }
    
    func updateUI(with theme: Theme) {
        let navFont = navigationController?.navigationBar.titleTextAttributes![NSFontAttributeName] as? UIFont
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: theme.textColor, NSFontAttributeName: theme.font(withSize: navFont?.pointSize ?? 30)]
        navigationController?.navigationBar.tintColor = theme.tintColor
        backgroundImageView.image = theme.mainImage.image
        let borderImage = theme.borderImage.image.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationController?.navigationBar.setBackgroundImage(borderImage, for: .default)
    }
    
}


// MARK: - Fileprivate 

extension ThemeSelectionViewController: UICollectionViewDelegate {
    
    fileprivate func setUp() {
        let nib = UINib(nibName: String(describing: ThemeCollectionViewCell.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ThemeCollectionViewCell.reuseIdentifier)
        
        let margin: CGFloat = 16
        let columns: CGFloat = 2
        let totalMarginSpace: CGFloat = margin * (columns + 1)
        let screenWidthMinusMargin: CGFloat = view.frame.size.width - totalMarginSpace
        let cellWidth = screenWidthMinusMargin / columns
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.2)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: 0, right: margin)
        collectionView.collectionViewLayout = flowLayout
        collectionView.dataSource = dataSource
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTheme = dataSource.themes[indexPath.item]
        if selectedTheme.isLocked {
            showProVC()
            AnalyticsHelper.logEvent(.themeChangeAttempt)
        } else if selectedTheme.id != core.state.currentUser?.themeID, let currentUser = core.state.currentUser {
            currentUser.themeID = selectedTheme.id
            core.fire(command: UpdateUser(user: currentUser))
            collectionView.reloadData()
            AnalyticsHelper.logEvent(.themeChanged)
        }
    }
    
    func showProVC() {
        let proVC = ProViewController.initializeFromStoryboard().embededInNavigationController
        present(proVC, animated: true, completion: nil)
    }

}
