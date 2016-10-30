//
//  GroupListViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 10/30/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class GroupListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var core = App.core
    var groups: [Group] {
        return core.state.groups.sorted { $0.lastViewedDate < $1.lastViewedDate }
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

}


// MARK: - Subscriber

extension GroupListViewController: Subscriber {
    
    func update(with state: AppState) {
        tableView.reloadData()
    }
    
}

extension GroupListViewController {
    
    func setUp() {
        tableView.rowHeight = 80.0
    }
    
}


// MARK: - TableView

extension GroupListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
}

