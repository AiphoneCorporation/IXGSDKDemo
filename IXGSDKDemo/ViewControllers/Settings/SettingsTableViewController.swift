//
//  SettingsTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/2/24.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1//TODO: The administrative section
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2//TODO: size of settings list
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Administration"
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsListCell", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Update Name"
        case 1:
            cell.textLabel?.text = "Move Out"
        default:
            print("Error: No setting found at index \(indexPath.row)")
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsListCell", for: indexPath)

        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: Segue.updateName.rawValue, sender: self)
        case 1:
            self.performSegue(withIdentifier: Segue.moveOut.rawValue, sender: self)
        default:
            print("Error: No setting found at index \(indexPath.row)")
        }
    }
}

extension SettingsTableViewController {
    enum Segue: String {
        case updateName = "updateName"
        case moveOut = "moveOut"
    }
}
