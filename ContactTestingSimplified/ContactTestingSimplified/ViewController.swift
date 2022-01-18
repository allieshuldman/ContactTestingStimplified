//
//  ViewController.swift
//  ContactTestingSimplified
//
//  Created by Allie Shuldman on 1/18/22.
//

import UIKit

class ViewController: UIViewController {

  let testButton = UIButton()
  let deleteButton = UIButton()

  var testing = false

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    testButton.setTitle("Test", for: .normal)
    testButton.addTarget(self, action: #selector(test), for: .touchUpInside)
    testButton.setTitleColor(.black, for: .normal)
    testButton.backgroundColor = .purple

    deleteButton.setTitle("Delete", for: .normal)
    deleteButton.addTarget(self, action: #selector(deleteContacts), for: .touchUpInside)
    deleteButton.setTitleColor(.black, for: .normal)
    deleteButton.backgroundColor = .red

    view.addSubview(testButton)
    view.addSubview(deleteButton)

    ContactStoreManager.shared.promptForAccessIfNeeded { [weak self] accessGranted in
      guard accessGranted else {
        DispatchQueue.main.async {
          let alertController = UIAlertController(title: "Please grant contact access in device settings", message: nil, preferredStyle: .alert)
          self?.present(alertController, animated: true, completion: nil)
        }
        return
      }
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    testButton.frame = CGRect(
      x: 0,
      y: 0,
      width: view.frame.width,
      height: view.frame.height / 2.0
    )

    deleteButton.frame = CGRect(
      x: 0,
      y: view.frame.height / 2.0,
      width: view.frame.width,
      height: view.frame.height / 2.0
    )
  }

  @objc func test() {
    guard !testing else {
      return
    }

    testing = true
    let inMemoryContacts = ContactListParser.shared.inMemoryContacts

    let start = Date()
    print("Start \(start)")
    let addResult = ContactStoreManager.shared.addContactsToDevice(inMemoryContacts)
    let end = Date()
    print("End \(end) \(addResult) Time: \(end.timeIntervalSince(start)) seconds")
    testing = false
  }

  @objc func deleteContacts() {
    guard !testing else {
      return
    }

    let start = Date()
    print("Deleting \(start)")
    let deleteResult = ContactStoreManager.shared.deleteAllContacts()
    let end = Date()
    print("Deleted \(end) \(deleteResult) Time: \(end.timeIntervalSince(start)) seconds")
  }
}

