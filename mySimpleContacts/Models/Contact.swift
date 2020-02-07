//
//  Contact.swift
//  mySimpleContacts
//
//  Created by Uzo on 2/7/20.
//  Copyright © 2020 Uzo. All rights reserved.
//

import Foundation
import CloudKit

struct ContactKeys {
    static let recordTypeKey = "Contact"
    fileprivate static let nameKey = "name"
    fileprivate static let phoneNumberKey = "phoneNumber"
    fileprivate static let emailAddressKey = "emailAddress"
}

class Contact {
    var name: String
    var phoneNumber: String?
    var emailAddress: String?
    var recordID: CKRecord.ID
    
    init(name: String, phoneNumber: String, emailAddress: String,  recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.recordID = recordID
    }
}

extension Contact {
    convenience init?(ckRecord: CKRecord) {
        
        guard let name = ckRecord[ContactKeys.nameKey] as? String,
            let phoneNumber = ckRecord[ContactKeys.phoneNumberKey] as? String,
            let emailAddress = ckRecord[ContactKeys.emailAddressKey] as? String
            else { return nil }
        
        self.init(name: name, phoneNumber: phoneNumber,
                  emailAddress: emailAddress,
                  recordID: ckRecord.recordID
        )
    }
}

extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: ContactKeys.recordTypeKey, recordID: contact.recordID)
        setValuesForKeys([
            ContactKeys.nameKey : contact.name,
            ContactKeys.phoneNumberKey: contact.phoneNumber ?? "",
            ContactKeys.emailAddressKey: contact.emailAddress ?? ""
        ])
    }
}

extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
