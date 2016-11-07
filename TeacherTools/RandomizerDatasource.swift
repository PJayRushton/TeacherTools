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
    var teamSize = 2
    let headerKey = "header"
    
    var sectionSize: Int {
        return students.count / teamSize
    }
    
    deinit {
        core.remove(subscriber: self)
    }
    
    override init() {
        super.init()
        core.add(subscriber: self)
    }

    var numberOfTeams: Int {
        return students.count / teamSize
    }
    
    func teamSize(forSection section: Int) -> Int {
        let remainder = students.count % teamSize
        if remainder != 0 && section == numberOfTeams {
            return teamSize + remainder
        }
        
        return teamSize
    }

    
    func students(inSection section: Int) -> [Student] {
        let lowBound = section * teamSize(forSection: section)
        let range = CountableRange(uncheckedBounds: (lowBound, lowBound + teamSize(forSection: section) - 1))
        return students.filter { range.contains(students.index(of: $0)!) }
//        var students = [Student]()
//        for (index, student) in students.enumerated() {
//            if range.contains(index) {
//                students.append(student)
//            }
//        }
//        return students
    }
    
    func student(at indexPath: IndexPath) -> Student {
        return students(inSection: indexPath.section)[indexPath.row]
    }
    
    func title(forSection section: Int) -> String {
        return "Team \(section + 1)"
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return students.count / teamSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return students(inSection: section).count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: headerKey, withReuseIdentifier: RandomizerHeaderView.reuseIdentifier, for: indexPath) as! RandomizerHeaderView
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
        guard let selectedGroup = state.selectedGroup else { teamSize = 2; return }
        teamSize = selectedGroup.teamSize
    }
    
}

