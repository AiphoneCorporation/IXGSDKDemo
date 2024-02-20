//
//  SettingsTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/2/24.
//

import UIKit
import AiphoneIntercomCorePkg

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
            cell.textLabel?.text = "Disconnect From IXG"
        default:
            print("Error: No setting found at index \(indexPath.row)")
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: Segue.updateName.rawValue, sender: self)
        case 1:
            disconnectFromIXG()
        default:
            print("Error: No setting found at index \(indexPath.row)")
        }
    }
    
    func disconnectFromIXG(){
        let alert = UIAlertController(title: "Disconnect from IXG", message: "This will unregister you from the IXG system and reset the app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            Task{
                let result = await RegistrationManager(session: .shared).deregister()
                
                switch result {
                case .success(_):
                    self.restartApplication()
                case .failure(let error):
                    print(error)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func restartApplication () {
        // TODO: clean up the window heirarchy
        performSegue(withIdentifier: Segue.deregistered.rawValue, sender: self)
    }
}

extension SettingsTableViewController {
    enum Segue: String {
        case updateName = "updateName"
        case deregistered = "appDeregisteredSegue"
    }
}
