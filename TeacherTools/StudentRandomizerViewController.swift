//
//  StudentRandomizerViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class StudentRandomizerViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var shuffleBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!

    var layout = UICollectionViewFlowLayout()
    let dataSource = RandomizerDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    @IBAction func shuffleButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    
}

extension StudentRandomizerViewController: Subscriber {
    
    func update(with state: AppState) {
        collectionView.reloadData()
        title = state.selectedGroup?.name
    }
    
}


extension StudentRandomizerViewController {
    
    func setUp() {
        collectionView.dataSource = dataSource
        collectionView.register(RandomizerHeaderView.self, forSupplementaryViewOfKind: "header", withReuseIdentifier: RandomizerHeaderView.reuseIdentifier)
        let margin: CGFloat = 16.0
        let screenWidthMinusMargin: CGFloat = view.bounds.size.width - (margin * 3)
        layout.itemSize = CGSize(width: screenWidthMinusMargin, height: screenWidthMinusMargin)
        collectionView.collectionViewLayout = layout
    }
    
}


// MARK: - Collectionview

extension StudentRandomizerViewController: UICollectionViewDelegate {
    
}
