//
//  ToolsViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

enum Tool {
    case lists
    case groups
    case drawNames
    case settings
    
    var image: UIImage? {
        switch self {
        case .lists:
            return UIImage(named: "lists")
        case .groups:
            return UIImage(named: "groups")
        case .drawNames:
            return UIImage(named: "hat")
        case .settings:
            return UIImage(named: "settings")
        }
    }
    var title: String {
        switch self {
        case .lists:
            return "Class List"
        case .groups:
            return "Groups"
        case .drawNames:
            return "Draw Names"
        case .settings:
            return "Manage"
        }
    }
    
    static let allValues = [Tool.lists, .groups, .drawNames, .settings]
}


class ToolsViewController: UIViewController, AutoStoryboardInitializable {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var core = App.core
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
    }

}


extension ToolsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let margin: CGFloat = 20.0
        let screenWidthMinusMargin = view.bounds.size.width / 2 - margin
        layout.itemSize = CGSize(width: screenWidthMinusMargin, height: screenWidthMinusMargin)
        collectionView.contentInset = UIEdgeInsetsMake(20, margin / 2, 0, margin / 2)
        collectionView.collectionViewLayout = layout
        collectionView.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Tool.allValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupToolCollectionViewCell.reuseIdentifier, for: indexPath) as! GroupToolCollectionViewCell
        cell.update(with: Tool.allValues[indexPath.item], theme: core.state.theme)
        return cell
    }
    
}
