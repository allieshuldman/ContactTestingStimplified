//
//  Contact.swift
//  ContactTestingSimplified
//
//  Created by Allie Shuldman on 1/18/22.
//

struct Contact: Hashable {
  let firstName: String
  let lastName: String
  let email: String
  let phoneNumber: Int
  let id: String

  var url: String {
    return id
  }

  var fullName: String {
    return "\(firstName) \(lastName)"
  }

  public var description: String {
    return "Name: \(firstName) \(lastName)\nEmail: \(email)\nPhone: \(phoneNumber)\nURL: \(url)"
  }
}

enum ContactConstants {
  static let groupName = "Contact-Testing"
  static let transactionAuthor = ""
  static let urlLabel = "Test"
  static let emailAddressLabel = "work"
  static let phoneNumberLabel = "home"
}
