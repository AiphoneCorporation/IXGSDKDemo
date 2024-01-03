//
//  StationListTableTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/2/24.
//

import UIKit
import AiphoneIntercomCorePkg

class StationsTableViewController: UITableViewController {
    var stations = [Station]()
    let stationsManager = StationsManager()

    static let cellId = "stationListCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        let response = stationsManager.fetchStations(auth: "TODO")
        switch response {
        case .success(let stations):
            self.stations = stations
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Building Name"
        default:
            return ""
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count//TODO: size of stations list
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StationsTableViewController.cellId, for: indexPath)
        if let station = stations[safeIndex: indexPath.row] {
            cell.textLabel?.text = station.name
            cell.detailTextLabel?.text = String(station.unitNumber)
        }

        cell.imageView?.image = UIImage(systemName: "hifispeaker.fill")
        return cell
    }
}

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex
        else { return nil }
        
        return self[index]
    }
}
