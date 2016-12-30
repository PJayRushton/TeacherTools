//
//  GroupSettingsViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/27/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class GroupSettingsViewController: UITableViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameSwitch: UISwitch!
    @IBOutlet weak var deleteLabel: UILabel!

    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var themeNameLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var upgradeLabel: UILabel!
    
    var core = App.core
    var group: Group? {
        return core.state.selectedGroup
    }
    fileprivate var saveBarButton = UIBarButtonItem()
    fileprivate var doneBarButton = UIBarButtonItem()
    fileprivate var flexy = UIBarButtonItem()
    fileprivate var toolbarTapRecognizer = UITapGestureRecognizer()
    fileprivate let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id977797579")
    fileprivate let versionLabel = UILabel()

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
    
    @IBAction func groupNameTextFieldChanged(_ sender: UITextField) {
        updateToolbar()
    }
    
    @IBAction func lastNameSwitchChanged(_ sender: UISwitch) {
        updateLastFirstPreference()
    }
    
    var isNewGroupName: Bool {
        guard groupNameTextField.isFirstResponder else { return false }
        guard let text = groupNameTextField.text else { return false }
        return text != group?.name
    }
    
    var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.tintColor = .white
        toolbar.barTintColor = App.core.state.theme.tintColor
        
        return toolbar
    }()
    
}

// MARK: - Subscriber

extension GroupSettingsViewController: Subscriber {
    
    func update(with state: AppState) {
        groupNameTextField.text = group?.name
        lastNameSwitch.isOn = state.currentUser?.lastFirst ?? false
        themeNameLabel.text = state.theme.name
        let proText = state.currentUser!.isPro ? "Thanks for upgrading to pro!" : "Upgrade to PRO!"
        upgradeLabel.text = proText
        updateUI(with: state.theme)
        tableView.reloadData()
    }
    
    func updateUI(with theme: Theme) {
        tableView.backgroundView = theme.mainImage.imageView
        let borderImage = theme.borderImage.image.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
        navigationController?.navigationBar.setBackgroundImage(borderImage, for: .default)
        lastNameSwitch.onTintColor = theme.tintColor
        groupNameTextField.textColor = theme.textColor
        groupNameTextField.font = theme.font(withSize: 19)
        shareImageView.tintColor = .white
        
        for label in [groupNameLabel, lastNameLabel, deleteLabel, themeLabel, themeNameLabel, rateLabel, shareLabel, upgradeLabel] {
            label?.font = theme.font(withSize: 17)
            label?.textColor = theme.textColor
        }
        upgradeLabel.textColor = core.state.currentUser!.isPro ? theme.textColor : .appleBlue
        deleteLabel.textColor = .red
        versionLabel.font = theme.font(withSize: 12)
        versionLabel.textColor = theme.textColor
    }
    
}


// MARK: Fileprivate

extension GroupSettingsViewController {
    
    func setUp() {
        groupNameTextField.inputAccessoryView = toolbar
        setupToolbar()
        setUpVersionFooter()
    }
    
    func showThemeSelectionVC() {
        let themeVC = ThemeSelectionViewController.initializeFromStoryboard()
        navigationController?.pushViewController(themeVC, animated: true)
    }
    
    func launchAppStore() {
        guard let appStoreURL = appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) else {
            core.fire(event: ErrorEvent(error: nil, message: "Error launching app store"))
            return
        }
        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
    }

    func launchShareSheet() {
        let textToShare = "Check out this great app for teachers called Teacher Tools. You can find it in the app store!"
        var objectsToShare: [Any] = [textToShare]
        
        if let appStoreURL = URL(string: "https://itunes.apple.com/us/app/teacher-tools-tool-for-teachers/id977797579?mt=8") {
            objectsToShare.append(appStoreURL)
        }
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, .addToReadingList, .assignToContact, .openInIBooks, .postToTencentWeibo, .postToVimeo, .print, .saveToCameraRoll, .postToWeibo, .postToFlickr]
        present(activityVC, animated: true, completion: nil)
    }
    
    func showProVC() {
        let proVC = ProViewController.initializeFromStoryboard().embededInNavigationController
        present(proVC, animated: true, completion: nil)
    }
    
    func showAlreadyProAlert() {
        let alert = UIAlertController(title: "Thanks for purchasing the PRO version", message: "If you haven't already, consider sharing this app with someone who would enjoy it, or rating it on the app store!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Rate", style: .default, handler: { _ in
            self.launchAppStore()
        }))
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { _ in
            self.launchShareSheet()
        }))
        alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentNoDeleteAlert() {
        let alert = UIAlertController(title: "You won't have any classes left!", message: "You'll have to add a new class first", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func presentDeleteConfirmation() {
        var message = "This cannot be undone"
        guard let group = group else { return }
        if group.studentIds.count > 0 {
            let studentKey = group.studentIds.count == 1 ? "student" : "students"
            message = "This class's \(group.studentIds.count) \(studentKey) will also be deleted."
        }
        let alert = UIAlertController(title: "Are you sure?", message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.core.fire(command: DeleteObject(object: group))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func saveClassName() {
        guard var group = group, let name = groupNameTextField.text else {
            core.fire(event: ErrorEvent(error: nil, message: "Error saving class"))
            return
        }
        let shouldSave = name.isEmpty == false && name != group.name
        if shouldSave {
            group.name = name
            core.fire(command: UpdateObject(object: group))
            core.fire(event: DisplaySuccessMessage(message: "Saved!"))
        } else {
            groupNameTextField.text = group.name
        }
        groupNameTextField.resignFirstResponder()
    }

    func toolbarTapped() {
        if isNewGroupName {
            saveClassName()
        } else {
            doneButtonPressed()
        }
    }
    
    func doneButtonPressed() {
        view.endEditing(true)
    }
    
    func setupToolbar() {
        flexy = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(toolbarTapped))
        saveBarButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(saveClassName))
        doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed))
        saveBarButton.setTitleTextAttributes([NSFontAttributeName: core.state.theme.font(withSize: 20)], for: .normal)
        toolbarTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toolbarTapped))
        toolbar.addGestureRecognizer(toolbarTapRecognizer)
        toolbar.setItems([flexy, saveBarButton, flexy], animated: false)
        updateToolbar()
    }
    
    func updateToolbar() {
        let items = isNewGroupName ? [flexy, saveBarButton, flexy] : [flexy, doneBarButton]
        toolbar.setItems(items, animated: false)
    }
    
    func updateLastFirstPreference() {
        guard let user = core.state.currentUser else {
            core.fire(event: NoOp())
            return
        }
        user.lastFirst = lastNameSwitch.isOn
        core.fire(command: UpdateUser(user: user))
    }
    
    fileprivate func setUpVersionFooter() {
        versionLabel.frame = CGRect(x: 0, y: -2, width: view.frame.size.width * 0.95, height: 20)
        versionLabel.font = core.state.theme.font(withSize: 12)
        versionLabel.textColor = core.state.theme.textColor
        versionLabel.textAlignment = .right
        versionLabel.text = versionDescription
        let footerView = UIView()
        footerView.addSubview(versionLabel)
        tableView.tableFooterView = footerView
    }

    fileprivate var versionDescription: String {
        let versionDescription = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        var version = "3.1"
        if let versionString = versionDescription {
            version = versionString
        }
        
        return "version: \(version)"
    }
    
}

// MARK: - UITextFieldDelegate

extension GroupSettingsViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateToolbar()
    }
    
}


// MARK: - UITableViewDelegate

extension GroupSettingsViewController {

    enum TableSection: Int {
        case group
        case app
        
        var rows: [TableRow] {
            switch self {
            case .group:
                return [.className, .lastFirst, .delete]
            case .app:
                return [.theme, .rate, .share, .pro]
            }
        }
    }
    
    enum TableRow {
        case className
        case lastFirst
        case delete
        case theme
        case rate
        case share
        case pro
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = core.state.theme.font(withSize: 17)
        label.textColor = core.state.theme.textColor
        label.textAlignment = .center
        headerView.addSubview(label)
        headerView.addConstraint(headerView.centerYAnchor.constraint(equalTo: label.centerYAnchor))
        headerView.addConstraint(headerView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: label.leadingAnchor))
        headerView.addConstraint(headerView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: label.trailingAnchor))
        
        let bottomLineView = UIView()
        bottomLineView.backgroundColor = tableView.separatorColor
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(bottomLineView)
        headerView.addConstraint(bottomLineView.heightAnchor.constraint(equalToConstant: 1))
        headerView.addConstraint(bottomLineView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor))
        headerView.addConstraint(bottomLineView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor))
        headerView.addConstraint(bottomLineView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor))
        
        switch TableSection(rawValue: section)! {
        case .group:
            label.text = "Group Settings"
        case .app:
            label.text = "App Settings"
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = TableSection(rawValue: indexPath.section)!
        let row = section.rows[indexPath.row]
        switch row {
        case .className:
            groupNameTextField.becomeFirstResponder()
        case .lastFirst:
            lastNameSwitch.isOn = !lastNameSwitch.isOn
            lastNameSwitchChanged(lastNameSwitch)
        case .delete:
            if core.state.groups.count == 1 {
                presentNoDeleteAlert()
            } else {
                presentDeleteConfirmation()
            }
        case .theme:
            showThemeSelectionVC()
        case .rate:
            launchAppStore()
        case .share:
            launchShareSheet()
        case .pro:
            guard let currentUser = core.state.currentUser, currentUser.isPro else {
                showProVC()
                return
            }
            showAlreadyProAlert()
        }
    }
    
}
