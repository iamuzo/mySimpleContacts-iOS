//
//  ContactDetailViewController.swift
//  mySimpleContacts
//
//  Created by Uzo on 2/7/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    // MARK: - PROPERTIES
    var contact: Contact? {
        didSet {
            loadViewIfNeeded()
            updateView()
        }
    }
    
    // MARK: - OUTLETS
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var contactPhoneNumberTextField: UITextField!
    @IBOutlet weak var contactEmailAddressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactNameTextField.delegate = self as UITextFieldDelegate
        contactPhoneNumberTextField.delegate = self as UITextFieldDelegate
        contactEmailAddressTextField.delegate = self as UITextFieldDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        customizeButtons()
    }
    
    // MARK: - CUSTOM METHODS
    func updateView() {
        loadViewIfNeeded()
        guard let existingContact = contact else { return }
        
        contactNameTextField.text = existingContact.name
        contactNameTextField.isEnabled = false
        contactPhoneNumberTextField.text = existingContact.phoneNumber
        contactPhoneNumberTextField.isEnabled = false
        contactEmailAddressTextField.text = existingContact.emailAddress
        contactEmailAddressTextField.isEnabled = false
    }
    
    func customizeButtons() {
        if contact != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editContactButtonTapped))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveContactButtonTapped))
        }
    }
    
    @objc func saveContactButtonTapped() {
        print("Save Contact Button Tapped; used to create a new Contact")
        
        guard let contactName = contactNameTextField.text, !contactName.isEmpty else { return }
        let contactPhoneNumber = contactPhoneNumberTextField.text ?? ""
        let contactEmailAddress = contactEmailAddressTextField.text ?? ""
        
        ContactController.sharedInstance.saveContact(with: contactName, phoneNumber: contactPhoneNumber, emailAddress: contactEmailAddress) { (result) in
            switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.updateView()
                        self.navigationController?.popViewController(animated: true)
                }
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    @objc func editContactButtonTapped() {
        contactNameTextField.isEnabled = true
        contactPhoneNumberTextField.isEnabled = true
        contactEmailAddressTextField.isEnabled = true
        
        let updateBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(updateContactButtonTapped))
        let cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelUpdateButtonTapped))
        navigationItem.rightBarButtonItems = [cancelBarButtonItem, updateBarButtonItem]
    }
    
    @objc func cancelUpdateButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func updateContactButtonTapped() {
        print("Update Contact Button Tapped")
        
        guard let existingContact = contact else { return }
        
        guard let editedContactName = contactNameTextField.text, !editedContactName.isEmpty else { return }
        let editedContactPhoneNumber = contactPhoneNumberTextField.text ?? ""
        let editedContactEmailAddress = contactEmailAddressTextField.text ?? ""
        
        existingContact.name = editedContactName
        existingContact.phoneNumber = editedContactPhoneNumber
        existingContact.emailAddress = editedContactEmailAddress
        
        ContactController.sharedInstance.updateContact(existingContact) { (result) in
            switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.updateView()
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    print(error)
            }
        }
        
    }
}

extension ContactDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
    }
}
