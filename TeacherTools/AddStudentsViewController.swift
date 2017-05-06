//
//  AddStudentsViewController.swift
//  TeacherTools
//
//  Created by Parker Rushton on 12/31/16.
//  Copyright © 2016 AppsByPJ. All rights reserved.
//

import UIKit

class AddStudentsViewController: UIViewController, AutoStoryboardInitializable {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var pasteButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var fakePlaceholderLabel: UILabel!

    var core = App.core
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsHelper.logEvent(.classPasteViewed)
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
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        guard let currentGroup = core.state.selectedGroup else {
            core.fire(event: ErrorEvent(error: nil, message: "Unable to save students"))
            return
        }
        if currentGroup.studentIds.isEmpty {
            saveStudents(replace: true)
        } else {
            showStudentOverrideAlert()
        }
    }
    
    @IBAction func pasteButtonPressed(_ sender: UIButton) {
        if textView.text.isEmpty {
            paste()
        } else {
            showPasteConfirmation()
        }
        AnalyticsHelper.logEvent(.classPasteUsed)
    }

    @IBAction func viewTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
}

// MARK: - Subscriber

extension AddStudentsViewController: Subscriber {
    
    func update(with state: AppState) {
        updateUI(with: state.theme)
    }
    
    func updateUI(with theme: Theme) {
        backgroundImageView.image = theme.mainImage.image
        textView.layer.borderColor = theme.textColor.cgColor
        textView.textColor = theme.textColor
        textView.font = theme.font(withSize: 19)
        fakePlaceholderLabel.textColor = theme.textColor.withAlphaComponent(0.4)
        fakePlaceholderLabel.font = theme.font(withSize: 19)
        pasteButton.titleLabel?.font = theme.font(withSize: 24)
        saveButton.setTitleTextAttributes([NSFontAttributeName: theme.font(withSize: 17)], for: .normal)
    }
    
}


extension AddStudentsViewController {
    
    func setUp() {
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        fakePlaceholderLabel.text = "If you already copied a class list, tap the paste button!\n\nOtherwise you can:\n1. Go copy a class list now and come back to paste it\n 2. Add students manually.\n\nTo manually add names:\nEnter names on separate lines. Either like this:\nJohn  - or this:\nJohn Doe  - or this:\nDoe, John"
        updateUIAfterKeystroke()
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func handleKeyboardDidShow(notification: NSNotification) {
        var keyboardHeight: CGFloat = 216
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight * 0.8, right: 0)
        textView.contentInset = insets
    }
    
    func handleKeyboardDidHide() {
        textView.contentInset = UIEdgeInsets.zero
    }

    func showPasteConfirmation() {
        let alert = UIAlertController(title: "Replace current text?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Paste", style: .default, handler: { _ in
            self.paste()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showStudentOverrideAlert() {
        let alert = UIAlertController(title: "You can either add these students or replace your current student list with this one", message: "Which would you like to do?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            self.saveStudents(replace: false)
        }))

        alert.addAction(UIAlertAction(title: "Replace", style: .destructive, handler: { _ in
            self.saveStudents(replace: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func saveStudents(replace: Bool) {
        let studentNames = textView.text.studentList()
        guard !studentNames.isEmpty else {
            core.fire(event: ErrorEvent(error: nil, message: "Error parsing student list"))
            return
        }
        core.fire(command: SaveStudentList(names: studentNames, replace: replace))
        _ = navigationController?.popViewController(animated: true)
    }

    func paste() {
        textView.text = UIPasteboard.general.string
        updateUIAfterKeystroke()
    }
    
    func updateUIAfterKeystroke() {
        let textViewHasText = !textView.text.isEmpty
        saveButton.isEnabled = textViewHasText
        fakePlaceholderLabel.isHidden = textViewHasText
    }
    
}


extension AddStudentsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateUIAfterKeystroke()
    }
    
}
