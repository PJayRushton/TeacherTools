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
        collectionView.reloadData()
        title = state.selectedGroup?.name
        guard let selectedGroup = state.selectedGroup else { return }
        sizeBarButton.title = "\(selectedGroup.teamSize)"
    }
    
}


extension StudentRandomizerViewController {
    
    func setUp() {
        var teamSize: CGFloat = 2.0
        if let selectedGroup = core.state.selectedGroup {
            teamSize = CGFloat(selectedGroup.teamSize)
            collectionView.dataSource = dataSource
            collectionView.register(RandomizerHeaderView.self, forSupplementaryViewOfKind: "header", withReuseIdentifier: RandomizerHeaderView.reuseIdentifier)
            let margin: CGFloat = 16.0
            let screenWidthMinusMargin: CGFloat = view.bounds.size.width - (margin * teamSize) / teamSize
            layout.itemSize = CGSize(width: screenWidthMinusMargin, height: screenWidthMinusMargin)
            collectionView.collectionViewLayout = layout
        }
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
