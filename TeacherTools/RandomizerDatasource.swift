//
//  RandomizerDataSource.swift
//  TeacherTools
//
//  Created by Parker Rushton on 11/6/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class RandomizerDataSource: NSObject, UICollectionViewDataSource {
    
    var core = App.core
    var students = [Student]()
    var absentStudents = [Student]()
    var teamSize = 2
    var group: Group? {
        didSet {
            guard group != oldValue else { return }
            absentStudents.removeAll()
        }
    }
    
    var remainder: Int {
        return students.count % teamSize
    }

    deinit {
        core.remove(subscriber: self)
    }
    
    override init() {
        super.init()
        core.add(subscriber: self)
    }

    var numberOfTeams: Int {
        // Rule of thumb: if there are more than 2 remainder students, they form their own group
        var standardNumberOfTeams = students.count / teamSize
        
        if absentStudents.count > 0 {
            standardNumberOfTeams += 1 // Absent students have their own section
        }
        if remainder == 2 && teamSize == 3 { // If team size is 3 and there are exactly 2 remaining, they also form their own group
            return standardNumberOfTeams + 1
        }
        return remainder > 2 ? standardNumberOfTeams + 1 : standardNumberOfTeams
    }
    
    func teamSize(forSection section: Int) -> Int {
        let hasAbsentSection = absentStudents.count > 0
        let isLastSection = hasAbsentSection ? section == numberOfTeams - 2 : section == numberOfTeams - 1
        
        if hasAbsentSection && section == numberOfTeams - 1 {
            return absentStudents.count
        }
        
        switch remainder {
        case 0:
            return teamSize
        case 1:
            if isLastSection {
                return teamSize + 1
            }
            return teamSize
        default:
            if isLastSection {
                return remainder
            }
            return teamSize
        }
    }
    
    func students(inSection section: Int) -> [Student] {
        if absentStudents.count > 0 && section == numberOfTeams - 1 {
            return absentStudents
        }
        
        let lowBoundSection = section == 0 ? 0 : section - 1
        let lowBound = section * teamSize(forSection: lowBoundSection)
        let highBound = lowBound + teamSize(forSection: section)
        return students.step(from: lowBound, to: highBound)
    }
    
    func student(at indexPath: IndexPath) -> Student {
        return students(inSection: indexPath.section)[indexPath.row]
    }
    
    func title(forSection section: Int) -> String {
        if section == numberOfTeams - 1 && absentStudents.count > 0 {
            return "ABSENT"
        }
        
        var headerString = "Team \(section + 1)"
        if teamSize(forSection: section) != teamSize {
            headerString +=  " (\(teamSize(forSection: section)))"
        }
        return headerString
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfTeams
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return students(inSection: section).count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RandomizerHeaderView.reuseIdentifier, for: indexPath) as! RandomizerHeaderView
        header.update(with: title(forSection: indexPath.section), theme: core.state.theme)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RandomizerCollectionViewCell.reuseIdentifier, for: indexPath) as! RandomizerCollectionViewCell
        cell.update(with: student(at: indexPath), theme: core.state.theme)
        
        return cell
    }
    
}


// MARK: - Subscriber

extension RandomizerDataSource: Subscriber {
    
    func update(with state: AppState) {
        students = state.currentStudents
        absentStudents = state.absentStudents
        guard let selectedGroup = state.selectedGroup else { teamSize = 2; return }
        teamSize = selectedGroup.teamSize
        group = selectedGroup
    }
    
}
