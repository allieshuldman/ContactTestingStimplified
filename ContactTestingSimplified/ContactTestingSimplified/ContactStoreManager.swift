//
//  ContactStoreManager.swift
//  ContactTestingSimplified
//
//  Created by Allie Shuldman on 1/18/22.
//

import Contacts
import Foundation

class ContactStoreManager {
  // MARK: - Result Types

  enum AddResult {
    case success
    case couldNotCreateGroup
    case couldNotAddContacts
    case failure(String)

    var description: String {
      switch self {
      case .success:
        return "Successfully added contacts"
      case .couldNotCreateGroup:
        return "Failed to create group"
      case .couldNotAddContacts:
        return "Failed to add contacts"
      case .failure(let error):
        return "Generic failure: \(error)"
      }
    }
  }

  enum DeleteResult {
    case success
    case groupDoesntExist
    case couldNotFetchContacts
    case couldNotDeleteGroup
    case couldNotDeleteContacts
    case failure(String)

    var description: String {
      switch self {
      case .success:
        return "Successfully deleted group"
      case .groupDoesntExist:
        return "Group already deleted"
      case .failure(let error):
        return "Failed to delete group \(error)"
      case .couldNotFetchContacts:
        return "Could not fetch contacts"
      case .couldNotDeleteGroup:
        return "Could not delete group"
      case .couldNotDeleteContacts:
        return "Could not delete contacts"
      }
    }
  }

  enum SearchResult {
    case success([CNContact], TimeInterval)
    case failure(SearchError)

    enum SearchError {
      case noIdentifier
      case enumerationError
      case fetchError

      var description: String {
        switch self {
        case .noIdentifier:
          return "Could not find identifier for contact"
        case .enumerationError:
          return "Could not enumerate contacts"
        case .fetchError:
          return "Could not fetch contacts"
        }
      }
    }
  }

  // MARK: - Contact Store Helpers

  static let shared = ContactStoreManager()
  private let store = CNContactStore()

  private var lastAppOpenChangeHistoryKey: Data?

  private var authorizationStatus: CNAuthorizationStatus {
    return CNContactStore.authorizationStatus(for: .contacts)
  }

  private var shouldPromptForAccess: Bool {
    switch authorizationStatus {
    case .notDetermined, .restricted, .denied:
      return true
    case .authorized:
      return false
    default:
      return true
    }
  }

  func promptForAccessIfNeeded(completion: @escaping (Bool) -> Void) {
    if shouldPromptForAccess {
      ContactStoreManager.shared.store.requestAccess(for: .contacts, completionHandler: {granted, _ in
        completion(granted)
      })
    }
    else {
      completion(true)
    }
  }

  // MARK: - Adding/Deleting from device

  func addContactsToDevice(_ contacts: [Contact]) -> AddResult {
    for contactBatch in createBatches(allContacts: contacts, batchSize: 100) {
      let saveRequest = CNSaveRequest()

      contactBatch.forEach {
        let cnContact = CNMutableContact($0)
        saveRequest.add(cnContact, toContainerWithIdentifier: nil)
      }

      do {
        try store.execute(saveRequest)
        print("Saved batch")
      }
      catch {
        return .couldNotAddContacts
      }
    }

    return .success
  }

  func deleteAllContacts() -> DeleteResult {
    var contacts = [CNContact]()

    do {
      let containers = try store.containers(matching: nil)
      for container in containers {
        let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
        contacts += try store.unifiedContacts(matching: fetchPredicate, keysToFetch: [])
      }
    }
    catch {
      return .couldNotFetchContacts
    }

    for contactBatch in createBatches(allContacts: contacts, batchSize: 100) {
      let deleteContactsRequest = CNSaveRequest()
      for cnContact in contactBatch {
        if let mutableContact = cnContact.mutableCopy() as? CNMutableContact {
          deleteContactsRequest.delete(mutableContact)
        }
      }
      do {
        try store.execute(deleteContactsRequest)
      }
      catch {
        return .couldNotDeleteContacts
      }
    }

    return .success
  }

  func createBatches<T>(allContacts: [T], batchSize: Int) -> [[T]] {
    var batches = [[T]]()
    let numberOfBatches = Int((Double(allContacts.count) / Double(batchSize)).rounded(.up))

    for batchIndex in 0..<numberOfBatches {
      let startIndex = batchSize * batchIndex
      let endIndex = min(allContacts.count, startIndex + batchSize)
      batches.append(Array(allContacts[startIndex..<endIndex]))
    }

    return batches
  }
}

// MARK: - CNMutableContact

extension CNMutableContact {
  convenience init(_ contact: Contact) {
    self.init()

    givenName = contact.firstName
    familyName = contact.lastName
    emailAddresses = [CNLabeledValue(label: ContactConstants.emailAddressLabel, value: NSString(string: contact.email))]
    phoneNumbers = [CNLabeledValue(label: ContactConstants.phoneNumberLabel, value: CNPhoneNumber(stringValue: String(contact.phoneNumber)))]
    urlAddresses = [CNLabeledValue(label: ContactConstants.urlLabel, value: NSString(string: contact.id))]
  }
}
