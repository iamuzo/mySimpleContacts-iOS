//
//  ContactsListTableViewController.swift
//  mySimpleContacts
//
//  Created by Uzo on 2/7/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import UIKit

class ContactsListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ContactController.sharedInstance.fetch { (result) in
            switch result {
                case .success(let contacts):
                    print(contacts)
                    self.updateViews()
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactController.sharedInstance.contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let contact = ContactController.sharedInstance.contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contactToDelete = ContactController.sharedInstance.contacts[indexPath.row]
            
            guard let index = ContactController.sharedInstance.contacts.firstIndex(of: contactToDelete) else {return}
            
            ContactController.sharedInstance.deleteContact(contactToDelete) { (result) in
                switch result {
                    case .success(let success):
                        if success {
                            ContactController.sharedInstance.contacts.remove(at: index)
                            DispatchQueue.main.async {
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                    }
                    case .failure(let error):
                        print(error.errorDescription ?? error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContactDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? ContactDetailViewController
                else { return }
            
            let selectedContact = ContactController.sharedInstance.contacts[indexPath.row]
            destinationVC.contact = selectedContact
        }
    }
}
