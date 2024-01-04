//
//  SlotSelectorTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 12/18/23.
//

import UIKit
import AiphoneIntercomCorePkg

class SlotSelectorTableViewController: UITableViewController {
    var registrationManager: RegistrationManager!
    var mobileAppStationsList: [IXGMobileAppStation]!
    var selectedStation: IXGMobileAppStation!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1//should only ever be 1 section of apps. cant select station in more than one unit at a time
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileAppStationsList.count//should either be 1 or 8, but we accept any
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "appSlotCell", for: indexPath)
        let stationListSlot = mobileAppStationsList[indexPath.row]//a given slot in the list
        
        if(stationListSlot.isOccupied){ cell.textLabel?.text = stationListSlot.name }//if the station tied to that slot is occupied, update the name
        else { cell.textLabel?.text = "Open slot \(indexPath.row + 1)" }//otherwise set it to generic open slot text
        
        cell.detailTextLabel?.text = String(stationListSlot.number) //TODO: add custom slot display with hint and assign hint here

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let slot = mobileAppStationsList[indexPath.row]
        
        if(slot.isOccupied) { return }//if user tapped on slot already occupied, do nothing
            
        selectedStation = slot//otherwise update the selected slot for confirmation screen
        
        performSegue(withIdentifier: Segue.slotDetails.rawValue, sender: self)//and move on to said screen
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? RegistrationConfirmationViewController else { return }
        vc.selectedSlot = selectedStation//DI selected app for station confirmation screen
        vc.registrationManager = registrationManager
    }
}

extension SlotSelectorTableViewController{
    enum Segue: String{
        case slotDetails = "confirmStation"
    }
}
