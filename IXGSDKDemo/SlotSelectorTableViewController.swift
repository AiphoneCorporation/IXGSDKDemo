//
//  SlotSelectorTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 12/18/23.
//

import UIKit
import AiphoneIntercomCorePkg

class SlotSelectorTableViewController: UITableViewController {
    
    var appSlots: [AppSlot]!
    var selectedApp: AppSlot!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appSlots.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "appSlotCell", for: indexPath)
        let appSlot = appSlots[indexPath.row]
        
        if(appSlot.isOccupied){ cell.textLabel?.text = appSlot.stationName }
        else { cell.textLabel?.text = "Open slot \(indexPath.row + 1)" }
        
        cell.detailTextLabel?.text = String(appSlot.stationNumber) //TODO: add custom slot display with hint and assign hint here

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let slot = appSlots[indexPath.row]
        
        if(slot.isOccupied) { return }
            
        selectedApp = slot
        
        performSegue(withIdentifier: Segue.slotDetails.rawValue, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? StationConfirmationViewController else { return }
        vc.selectedSlot = selectedApp
    }
}

extension SlotSelectorTableViewController{
    enum Segue: String{
        case slotDetails = "confirmStation"
    }
}
