//
//  StationListTableTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/2/24.
//

import UIKit
import AiphoneIntercomCorePkg

class StationsTableViewController: UITableViewController {
    let stationsManager = StationsManager(session: .shared)
    let searchController = UISearchController(searchResultsController: nil)//handles search bar and tab bar
    var allStations = [IXGStation]()
    var filteredStations = [IXGStation]()
    var selectedStation: IXGStation? = nil

    static let cellId = "stationListCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        Task{
            let response = await stationsManager.getStations()
            switch response {
            case .success(let stations):
                self.allStations = stations
                filteredStations = stations
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            self.configureSearchController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedStation = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StationsTableViewController.cellId, for: indexPath)
        if let station = filteredStations[safeIndex: indexPath.section] {
            cell.textLabel?.text = station.name
            cell.detailTextLabel?.text = station.capabilityDescription
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let station = filteredStations[safeIndex: indexPath.row] else { return }
        selectedStation = station
        let stationTitle = station.name
            
        print(stationTitle)
        let alertController = UIAlertController(title: stationTitle, message: station.capabilityDescription, preferredStyle: .actionSheet)
        let callAction = UIAlertAction(title: "Call", style: .default) { action in
            print(action)
            self.performSegue(withIdentifier: Segue.callStation.rawValue, sender: self)
        }
        let monitorAction = UIAlertAction(title: "Monitor", style: .default) { action in
            print(action)
            self.performSegue(withIdentifier: Segue.monitorStation.rawValue, sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print(action)
            self.selectedStation = nil
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
    
    enum Segue: String{
        case callStation = "callStation"
        case monitorStation = "monitorStation"
    }
    
    
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
            filteredStations = allStations
            tableView.reloadData()
            return
        }
        
        filteredStations = allStations.filter { $0.isMatch(for: searchText) }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? CallViewController else { return }
        guard selectedStation != nil else {
            assertionFailure("Cannot communicate with nil station")
            return
        }
        vc.station = selectedStation
        switch segue.identifier {
        case Segue.callStation.rawValue:
            vc.callType = Segue.callStation.rawValue
        case Segue.monitorStation.rawValue:
            vc.callType = Segue.monitorStation.rawValue
        default:
            assertionFailure("No segue identifier")
        }
    }
}

extension IXGStation {
    func isMatch(for searchText: String) -> Bool {
        return self.name.lowercased().contains(searchText.lowercased())
    }
}
