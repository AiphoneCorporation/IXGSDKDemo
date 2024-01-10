//
//  StationListTableTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/2/24.
//

import UIKit
import AiphoneIntercomCorePkg

class StationsTableViewController: UITableViewController {
    var allUnits = [IXGUnit]()
    let stationsManager = StationsManager()
    let searchController = UISearchController(searchResultsController: nil)//handles search bar and tab bar
    var filteredUnits = [IXGUnit]()

    static let cellId = "stationListCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        let response = stationsManager.fetchUnits(auth: "TODO")
        switch response {
        case .success(let units):
            self.allUnits = units
            filteredUnits = units
        case .failure(let error):
            print(error.localizedDescription)
        }
        
        self.configureSearchController()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let unit = filteredUnits[safeIndex: section] {
            return String("Unit \(unit.number)")
        }
        else { return "" }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return filteredUnits.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let unit = filteredUnits[safeIndex: section] {
            return unit.stations.count
        }
        else { return 0 }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StationsTableViewController.cellId, for: indexPath)
        if let station = filteredUnits[safeIndex: indexPath.section]?.stations[safeIndex: indexPath.row] {
            cell.textLabel?.text = station.name

            cell.detailTextLabel?.text = station.capabilityDescription
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let unit = filteredUnits[safeIndex: indexPath.section] else { return }
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

extension StationsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func configureSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {

        guard let searchText = searchController.searchBar.text, searchText != "" else {
            filteredUnits = allUnits
            tableView.reloadData()
            return
        }

        filteredUnits = allUnits.map({ unit in
            let filteredStations = unit.stations(matching: searchText)
            return IXGUnit(number: unit.number, stations: filteredStations)
        })
        tableView.reloadData()
    }
}

extension IXGUnit {
    func stations(matching searchText: String) -> [IXGStation] {
        return self.stations.filter { $0.isMatch(for: searchText) }
    }
}

extension IXGStation {
    func isMatch(for searchText: String) -> Bool {
        return self.name.lowercased().contains(searchText.lowercased())
    }
}
