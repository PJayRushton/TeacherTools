//
//  StudentRandomizerViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/2/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class StudentRandomizerViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate let dataSource = RandomizerDataSource()
    fileprivate let margin: CGFloat = 16.0
    fileprivate let maxHeight: CGFloat = Platform.isPad ? 80 : 60
    fileprivate let minHeaderHeight: CGFloat = Platform.isPad ? 40 : 28
    fileprivate var core = App.core
    fileprivate var layout = UICollectionViewFlowLayout()
    
    var rowHeight: CGFloat = 44.0 {
        didSet {
            guard rowHeight != oldValue else { return }
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    var headerHeight: CGFloat = 50.0 {
        didSet {
            guard headerHeight != oldValue else { return }
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    var shouldHideInstructions: Bool {
        get {
            return UserDefaults.standard.bool(forKey: #function)
        } set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
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
        shuffleStudents()
    }
    
    
}


// MARK: - Subscriber

extension StudentRandomizerViewController: Subscriber {
    
    func update(with state: AppState) {
        navigationItem.title = state.selectedGroup?.name
        guard let selectedGroup = state.selectedGroup else { return }
        updateCollectionView(group: selectedGroup)
        updateUI(with: state.theme)
    }
    
}


// MARK: - Private

private extension StudentRandomizerViewController {
    
    func setUp() {
        collectionView.dataSource = dataSource
        collectionView.contentInset = UIEdgeInsets.zero
        collectionView.collectionViewLayout = layout
        
        if shouldHideInstructions {
            instructionLabel.isHidden = true
        } else {
            shouldHideInstructions = true
        }
    }
    
    func updateCollectionView(group: Group) {
        let teamSize = CGFloat(group.teamSize)
        let columns = min(teamSize, 4)
        let totalMarginSpace: CGFloat = margin * (columns + 1)
        let screenWidthMinusMargin: CGFloat = view.frame.size.width - totalMarginSpace
        rowHeight = maxHeight * CGFloat(group.displayDensity)
        headerHeight = max(rowHeight * 1.1, minHeaderHeight)
        layout.itemSize = CGSize(width: screenWidthMinusMargin / columns, height: rowHeight)
        layout.sectionHeadersPinToVisibleBounds = true
        layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: headerHeight)
        collectionView.reloadData()
    }
    
    func updateUI(with theme: Theme) {
        backgroundImageView.image = theme.mainImage.image
        let borderImage = theme.borderImage.image.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationController?.navigationBar.setBackgroundImage(borderImage, for: .default)
        instructionLabel.font = theme.font(withSize: 17)
        instructionLabel.textColor = theme.textColor
    }
    
    func shuffleStudents() {
        dataSource.students.shuffle()
    }

}


// MARK: - Collectionview

extension StudentRandomizerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
    }
    
}

extension StudentRandomizerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let currentUser = core.state.currentUser, currentUser.isPro {
            let studentAtItem = dataSource.student(at: indexPath)
            if dataSource.absentStudents.isEmpty == false && indexPath.section == dataSource.numberOfTeams - 1 {
                core.fire(event: MarkStudentPresent(student: studentAtItem))
            } else {
                core.fire(event: MarkStudentAbsent(student: studentAtItem))
            }
        } else {
            let proVC = ProViewController.initializeFromStoryboard().embededInNavigationController
            present(proVC, animated: true, completion: nil)
        }
    }
    
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

// MARK: - PopoverDelegate

extension StudentRandomizerViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

}
