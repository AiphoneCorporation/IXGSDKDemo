//
//  StationListTableTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/2/24.
//

import UIKit
import AiphoneIntercomCorePkg

class StationsTableViewController: UITableViewController {
    var units = [IXGUnit]()
    let stationsManager = StationsManager()

    static let cellId = "stationListCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        let response = stationsManager.fetchUnits(auth: "TODO")
        switch response {
        case .success(let units):
            self.units = units
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let unit = units[safeIndex: section] {
            return String("Unit \(unit.number)")
        }
        else { return "" }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return units.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let unit = units[safeIndex: section] {
            return unit.stations.count
        }
        else { return 0 }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StationsTableViewController.cellId, for: indexPath)
        if let station = units[safeIndex: indexPath.section]?.stations[safeIndex: indexPath.row] {
            cell.textLabel?.text = station.name

            cell.detailTextLabel?.text = station.capabilityDescription
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let unit = units[safeIndex: indexPath.section] else { return }
        guard let station = unit.stations[safeIndex: indexPath.row] else { return }
        let stationTitle = "\(station.name) in Unit \(String(unit.number))"
            
        print(stationTitle)
        let alertController = UIAlertController(title: stationTitle, message: station.capabilityDescription, preferredStyle: .actionSheet)
        let callAction = UIAlertAction(title: "Call", style: .default) { action in
            print(action)
        }
        let monitorAction = UIAlertAction(title: "Monitor", style: .default) { action in
            print(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print(action)
        }
        alertController.addAction(callAction)
        alertController.addAction(monitorAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
}

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex
        else { return nil }
        
        return self[index]
    }
}

extension IXGStation {
    var capabilityDescription: String{
        switch self.hasVideo {
        case true:
            return "Audio/Video"
        case false:
            return "Audio Only"
        }
    }
}
