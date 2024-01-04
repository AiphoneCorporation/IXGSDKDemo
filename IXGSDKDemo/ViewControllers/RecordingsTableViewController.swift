//
//  RecordingsTableViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/2/24.
//

import UIKit
import AiphoneIntercomCorePkg

class RecordingsTableViewController: UITableViewController {
    let searchController = UISearchController(searchResultsController: nil)
    let scopeButtons = RecordingsFilterScope.allCases.map{ $0 }
    let allRecordings = [
        CallRecord(unitName: "kathy", stationName: "Front Door", unitNumber: 1001, callStarted: Date(), duration: 10, isManual: true),
        CallRecord(unitName: "jo", stationName: "back Door", unitNumber: 1002, callStarted: Date(), duration: 15, isManual: false),
        CallRecord(unitName: "steve", stationName: "side Door", unitNumber: 1003, callStarted: Date(), duration: 5, isManual: false),
        CallRecord(unitName: "bob", stationName: "closet", unitNumber: 1004, callStarted: Date(), duration: 6, isManual: false),
        CallRecord(unitName: "cody", stationName: "west hall", unitNumber: 1005, callStarted: Date(), duration: 900, isManual: true)
    ]
    private(set) var filteredRecordings: [CallRecord] = []
    private var scopeButton: RecordingsFilterScope = .auto

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureSearchController()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRecordings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordingsListCell", for: indexPath)

        let recording = allRecordings[indexPath.row]
        
        // Configure the cell...
        cell.textLabel?.text = "Call with \(recording.stationName) at time \(recording.callStarted)"

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RecordingsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func configureSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = .search
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["Auto", "Manual"]
        searchController.searchBar.showsScopeBar = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let selectedScopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        let buttonScope = scopeButtons[selectedScopeButtonIndex]
        filterRecordingsBySearchScope(scope: buttonScope)
        tableView.reloadData()
    }
    
    func filterRecordingsBySearchScope(scope: RecordingsFilterScope) {
        scopeButton = scope
        
        filteredRecordings = allRecordings.filter({ record in
            switch scope {
            case .auto:
                return record.isManual == false
            case .manual:
                return record.isManual == true
            }
        })
    }
    
    enum RecordingsFilterScope: CaseIterable {
        case auto
        case manual
    }
}
