//
//  ContactController.swift
//  mySimpleContacts
//
//  Created by Uzo on 2/7/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    
    // MARK: PROPERTIES
    var contacts: [Contact] = []
    static let sharedInstance = ContactController()
    let privateDB = CKContainer.default().privateCloudDatabase
    
    func saveContact(with name: String,
                     phoneNumber: String,
                     emailAddress: String,
                     completion: @escaping (Result<Contact, ContactError>) -> Void) {
        
        let contact = Contact(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress)
        
        let record = CKRecord(contact: contact)
        
        privateDB.save(record) { (record, error) in
            
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.throwError(error)))
            }
            
            guard let record = record else {
                return completion(.failure(.noData))
            }
            
            guard let contact = Contact(ckRecord: record) else {
                return completion(.failure(.unableToDecode))
            }
            
            self.contacts.append(contact)
            completion(.success(contact))
        }
    }
    
    func fetch(completion: @escaping (Result<[Contact], ContactError>) -> Void) {
        
        let queryAllPredicate = NSPredicate(value: true)
        
        let query = CKQuery(
            recordType: ContactKeys.recordTypeKey,
            predicate: queryAllPredicate
        )
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.throwError(error)))
            }
            
            guard let records = records else {
                return completion(.failure(.noData))
            }
            
            let fetchedContacts = records.compactMap {
                (record) -> Contact? in
                Contact(ckRecord: record)
            }
            
            self.contacts = fetchedContacts
            completion(.success(fetchedContacts))
        }
    }
    
    func updateContact(_ contact: Contact,
                       completion: @escaping (Result<Contact?, ContactError>) -> Void) {
        
        let record = CKRecord(contact: contact)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operation.savePolicy = .changedKeys
        
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.throwError(error)))
            }
            
            guard let record = records?.first,
                let updatedContact = Contact(ckRecord: record)
                else { return completion(.failure(.unableToDecode)) }
            completion(.success(updatedContact))
        }
        privateDB.add(operation)
    }
    
    func deleteContact(_ contact: Contact, completion: @escaping (Result<Bool, ContactError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.recordID])
        
        operation.savePolicy  = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsCompletionBlock = { records, _, error in

            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.throwError(error)))
            }
            
            if records?.count == 0 {
                print("Deleted record from CloudKit")
                return completion(.success(true))
            } else {
                print("Unable to delete record")
                return completion(.failure(.noData))
            }
        }
        privateDB.add(operation)
    }
}


enum ContactError: LocalizedError {
    case throwError(Error)
    case noData
    case unableToDecode
}
