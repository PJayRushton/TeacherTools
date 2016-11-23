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
    @IBOutlet weak var sizeBarButton: UIBarButtonItem!

    var core = App.core
    var layout = UICollectionViewFlowLayout()
    let dataSource = RandomizerDataSource()
    let margin: CGFloat = 16.0
    
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

    @IBAction func shuffleButtonPressed(_ sender: UIBarButtonItem) {
        core.fire(event: ShuffleTeams())
    }
    
    
}

extension StudentRandomizerViewController: Subscriber {
    
    func update(with state: AppState) {
        title = state.selectedGroup?.name
        guard let selectedGroup = state.selectedGroup else { return }
        sizeBarButton.title = "\(selectedGroup.teamSize)"
        updateCollectionView(group: selectedGroup)
    }
    
}


extension StudentRandomizerViewController {
    
    func setUp() {
        collectionView.dataSource = dataSource
        collectionView.contentInset = UIEdgeInsets(top: margin, left: margin, bottom: 0, right: margin)
        collectionView.collectionViewLayout = layout
    }
    
    func updateCollectionView(group: Group) {
        let teamSize = CGFloat(group.teamSize)
        let rows = min(teamSize, 4)
        print("rows: \(rows)")
        let screenWidthMinusMargin: CGFloat = collectionView.bounds.size.width - (margin * rows)
        print("screenWidth: \(view.bounds.width)")
        print("CV Width: \(collectionView.bounds.width)")
        layout.itemSize = CGSize(width: screenWidthMinusMargin / rows, height: 44)
        print("Cell width: \(screenWidthMinusMargin / rows)")
        layout.sectionHeadersPinToVisibleBounds = true
        layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 36)
        collectionView.reloadData()
    }
    
}


// MARK: - Collectionview

extension StudentRandomizerViewController: UICollectionViewDelegate {
    
}

// MARK: - Popover

extension StudentRandomizerViewController: SegueHandling {

    enum SegueIdentifier: String {
        case presentTeamSizeSelection
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .presentTeamSizeSelection:
            let teamSizeVC = segue.destination
            teamSizeVC.popoverPresentationController?.delegate = self
        }
    }

}


extension StudentRandomizerViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

}
